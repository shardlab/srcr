class Srcom::Api::Runs
  Log = Srcom::Log.for("runs")

  # Searches through all `Run`s using the given query parameters.
  #
  # Searching by *guest* requires a `Guest`'s name.
  #
  # Setting *emulated* to `true` returns only runs done on an emulated system. Setting it to `false`
  # will return both runs that are done on an emulated and runs that done on a real system.
  #
  # Possible values for *status*: "new", "verified", or "rejected".
  #
  # All other search parameters must be an ID.
  #
  # Possible values for *order_by*: "category", "level", "platform", "region", "emulated", "date",
  # "submitted", "status", "game", or "verify-date", with the default being "game".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # NOTE: Not specifying any filter probably leads to the request eventually crashing, leading to incomplete data.
  #
  # NOTE: Since `Run`s are very large objects this method defaults to very low results per page
  # to give the request a reasonable speed and the best odds at the request suceeding.
  def self.find_by(user : String? = nil,
                   guest : String? = nil,
                   examiner : String? = nil,
                   game : String? = nil,
                   level : String? = nil,
                   category : String? = nil,
                   platform : String? = nil,
                   region : String? = nil,
                   emulated : Bool = false,
                   status : String? = nil,
                   order_by : String? = nil,
                   sort_direction : String? = nil,
                   all_pages : Bool = false,
                   max_results_per_page : Int32 = 20) : Array(Run)
    options = Hash(String, String).new
    options["user"] = user if user
    options["guest"] = guest if guest
    options["examiner"] = examiner if examiner
    options["game"] = game if game
    options["level"] = level if level
    options["category"] = category if category
    options["platform"] = platform if platform
    options["region"] = region if region
    options["emulated"] = "true" if emulated

    case status
    when Nil
      # Do nothing
    when "new", "verified", "rejected"
      options["status"] = status
    else
      Log.warn { %([/runs] Unsupported status #{status}. Valid options are: "new", "verified", or "rejected".) }
    end

    order = case order_by
            when Nil
              # Do nothing
            when "category", "level", "platform", "region", "emulated", "date", "submitted", "status", "game"
              order_by
            when "verify_date", "verify-date", "verifydate"
              "verify-date"
            else
              Log.warn { %([/runs] Unsupported sorting option "#{order_by}". Valid options are "category", "level", "platform", "region", "emulated", "date", "submitted", "status", "game", and "verify-date". Defaulting to "game".) }
              "game"
            end

    if order
      options["orderby"] = order

      if sort_direction == "desc"
        options["direction"] = "desc"
      else
        options["direction"] = "asc"
      end
    end

    if max_results_per_page > 200
      max_results_per_page = 200
      Log.warn { "[/runs] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = max_results_per_page.to_s

    return request_runs(options, all_pages).map { |raw| Run.from_json(raw.to_json) }
  end

  # Gets a `Run` given its *id*.
  def self.get_by_id(id : String) : Srcom::Run
    id = URI.encode(id)
    return Run.from_json(request_single_run(id).to_json)
  end

  # Submits a `Run::Submission` to speedrun.com in the name of the user authenticated
  # with the given *api_key*, returning the newly submitted run as a `SimpleRun` if the
  # submission was successful.
  #
  # While most fields of a `Run::Submission` are optional it is highly recommended to fill out
  # as many of them as possible.
  #
  # NOTE: It is very important to respect the notes listed for `Run::Submission.new`!
  def self.submit(run : Srcom::Run::Submission, api_key : String) : Srcom::SimpleRun
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key
    body = %({"run": #{run.to_json}})

    return SimpleRun.from_json(submit_run(headers, body).to_json)
  end

  # Verifies the `Run` with the given *id* as the user authenticated using the given *api_key*,
  # returning the newly verified run if successful.
  #
  # NOTE: Obviously the authenticated user must be a moderator for the game the run was submitted
  # to, or a global moderator.
  def self.verify(id : String, api_key : String) : Srcom::SimpleRun
    id = URI.encode(id)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key
    body = %({"status": {"status": "verified"}})

    return SimpleRun.from_json(change_run_status(id, headers, body).to_json)
  end

  # Rejects the `Run` with the given *id* for the given *reason* as the user authenticated
  # using the given *api_key*, returning the newly verified run if successful.
  #
  # NOTE: Obviously the authenticated user must be a moderator for the game the run was submitted
  # to, or a global moderator.
  def self.reject(id : String, reason : String, api_key : String) : Srcom::SimpleRun
    id = URI.encode(id)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key
    body = %({"status": {"status": "rejected", "reason": "#{reason}"}})

    return SimpleRun.from_json(change_run_status(id, headers, body).to_json)
  end

  # Changes the status of the `Run` with the given *id* to the given *status*, which must either be
  # "verified" or "rejected", with the given *reason* if the new status should be *rejected*, in the
  # name of the user authenticated with the given *api_key*, returning the run if successful.
  #
  # NOTE: Obviously the authenticated user must be a moderator for the game the run was submitted
  # to, or a global moderator.
  #
  # NOTE: This method exists only to retain an exact mapping to the API's methods. It is highly
  # recommended to use the `.verify` and `.reject` methods instead of this!
  def self.change_status(id : String, status : String, api_key : String, reason : String? = nil) : Srcom::SimpleRun
    id = URI.encode(id)
    case status
    when "verified", "verfiy"
      verfiy(id, api_key)
    when "rejected", "reject"
      raise "Can't reject run without reason!" if reason.nil?
      reject(id, reason, api_key)
    else
      raise "Unknown status: #{status}."
    end
  end

  # Changes the players who played the `Run` with the given *id* to *players* in the name of the
  # user authenticated with the given *api_key*, returning the changed run if successful.
  #
  # BUG: Currently using this method will always return 500 Internal Server Error for an unknown
  # reason. Unfortunately, since the fault lies on speedrun.com's side, this can not be fixed.
  #
  # NOTE: Obviously the authenticated user must be a moderator for the game the run was submitted
  # to, or a global moderator.
  def self.change_players(id : String, players : Array(Run::Submission::Player), api_key : String) : Srcom::SimpleRun
    id = URI.encode(id)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key
    body = %({"players": #{players.to_json}})

    return SimpleRun.from_json(change_run_players(id, headers, body).to_json)
  end

  # Deletes the `Run` with the given *id* as the user authenticated using the given *api_key*,
  # returning the newly verified run if successful.
  #
  # NOTE: Obviously the authenticated user must be a moderator for the game the run was submitted
  # to, or a global moderator.
  def self.delete(id : String, api_key : String) : Srcom::SimpleRun
    id = URI.encode(id)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key

    return SimpleRun.from_json(delete_run(id, headers).to_json)
  end

  protected def self.request_runs(options : Hash(String, String), all_pages : Bool)
    params = URI::Params.encode(options)
    url = "#{BASE_URL}runs?embed=game,category.variables,category.game,level.categories.variables,level.variables,level.categories.game,players,region,platform&#{params}"

    return Api.request("/runs", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_run(id : String)
    url = "#{BASE_URL}runs/#{id}?embed=game,category.variables,category.game,level.categories.variables,level.variables,level.categories.game,players,region,platform"

    return Api.request_single_item("/runs/#{id}", url, "GET")
  end

  protected def self.submit_run(headers : HTTP::Headers, body : String)
    url = "#{BASE_URL}runs"

    return Api.request_single_item("/runs", url, "POST", headers, body)
  end

  protected def self.change_run_status(id : String, headers : HTTP::Headers, body : String)
    url = "#{BASE_URL}runs/#{id}/status"

    return Api.request_single_item("/runs/#{id}/status", url, "PUT", headers, body)
  end

  protected def self.change_run_players(id : String, headers : HTTP::Headers, body : String)
    url = "#{BASE_URL}runs/#{id}/players"

    return Api.request_single_item("/runs/#{id}/players", url, "PUT", headers, body)
  end

  protected def self.delete_run(id : String, headers : HTTP::Headers)
    url = "#{BASE_URL}runs/#{id}"

    return Api.request_single_item("/runs/#{id}", url, "DELETE", headers)
  end
end
