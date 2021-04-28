class Srcom::Api::Levels
  Log = Srcom::Log.for("levels")

  # Gets a `Level` given its *id*.
  def self.find_by_id(id : String) : Srcom::Level
    id = URI.encode(id)

    return Level.from_json(request_single_level(id).to_json)
  end

  # Gets the categories applicable to the `Level` given by its *id*.
  #
  # Possible values for *order_by*: "name", "miscellaneous", or "pos", with the default being "pos".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # NOTE: If *miscellaneous* is set to `true` only miscellaneous categories will be returned.
  # If it is set to `false` only non-miscellaneous categories will be returned.
  # If it is set to `nil` both miscellaneous and non-miscellaneous categories will be returned.
  def self.get_categories(id : String,
                          miscellaneous : Bool? = nil,
                          order_by : String? = nil,
                          sort_direction : String? = nil) : Array(Category)
    id = URI.encode(id)

    options = Hash(String, String).new

    unless miscellaneous.nil?
      options["miscellaneous"] = miscellaneous.to_s
    end

    order = case order_by
            when Nil
              # Do nothing
            when "name", "miscellaneous", "pos"
              order_by
            else
              Log.warn { %([/levels/<id>/categories] Unsupported sorting option "#{order_by}". Valid options are "name", "miscellaneous", and "pos". Defaulting to "pos".) }
              "pos"
            end

    if order
      options["orderby"] = order

      if sort_direction == "desc"
        options["direction"] = "desc"
      else
        options["direction"] = "asc"
      end
    end

    return request_level_categories(id, options).map { |category| Category.from_json(category.to_json) }
  end

  # Gets the `Variable`s applicable to the `Level` given by its *id*.
  #
  # Possible values for *order_by*: "name", "mandatory", "pos" or "user-defined", with the default being "pos".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  def self.get_variables(id : String, order_by : String? = nil, sort_direction : String? = nil) : Array(Variable)
    id = URI.encode(id)

    options = Hash(String, String).new

    order = case order_by
            when Nil
              # Do nothing
            when "name", "mandatory", "pos"
              order_by
            when "user_defined", "user-defined", "userdefined"
              "user-defined"
            else
              Log.warn { %([/levels/<id>/variables] Unsupported sorting option "#{order_by}". Valid options are "name", "mandatory", "user-defined", and "pos". Defaulting to "pos".) }
              "pos"
            end

    if order
      options["orderby"] = order

      if sort_direction == "desc"
        options["direction"] = "desc"
      else
        options["direction"] = "asc"
      end
    end

    return request_level_variables(id, options).map { |variable| Variable.from_json(variable.to_json) }
  end

  # Gets the `Leaderboard`s with the *top* N runs for the `Level` with the given *id*,
  # skipping over empty `Leaderboard`s if *skip_empty* is `true`.
  #
  # NOTE: This can result in more than N runs per `Leaderboard`, as ties can occur.
  # NOTE: This returns one `Leaderboard` for each `Category` that the `Level` can be played in.
  def self.get_records(id : String,
                       top : Int32 = 3,
                       skip_empty : Bool = false,
                       page_size : Int32 = 200) : PageIterator(Leaderboard)
    options = Hash(String, String).new
    options["top"] = top.to_s
    options["skip-empty"] = skip_empty.to_s

    if page_size > 200
      page_size = 200
      Log.warn { "[/levels/#{id}/records] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_level_records(id, options)
  end

  protected def self.request_single_level(id : String)
    url = "#{BASE_URL}levels/#{id}?embed=variables,categories.variables,categories.game"

    return Api.request_single_item("/levels/#{id}", url, "GET")
  end

  protected def self.request_level_categories(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}levels/#{id}/categories?embed=variables,game&#{params}"

    elements, _next = Api.request("/levels/#{id}/categories", url, "GET")
    return elements
  end

  protected def self.request_level_variables(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}levels/#{id}/variables?&#{params}"

    elements, _next = Api.request("/levels/#{id}/variables", url, "GET")
    return elements
  end

  protected def self.request_level_records(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}levels/#{id}/records?embed=game,category.variables,category.game,level.categories.variables,level.categories.game,level.variables,players,regions,platforms,variables&#{params}"

    data, next_page_uri = Api.request("/levels/#{id}/records", url, "GET")
    elements = data.map { |raw| Leaderboard.from_json(raw.to_json) }
    return PageIterator(Leaderboard).new(
      endpoint: "/levels/#{id}/records",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end
end
