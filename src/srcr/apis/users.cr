class Srcom::Api::Users
  Log = Srcom::Log.for("users")

  # Searches through all `User`s using the given query parameters.
  #
  # Using *lookups* performs an exact-match search across all usernames, URLs and social profiles.
  #
  # Searching by *name* searches for the substring across usernames and URLs.
  #
  # All other parameters search across users' names on the respective platform.
  #
  # Possible values for *order_by*: "name.jap", "name.int", "signup", or "role", with the default being "name.int".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # BUG: Not specifying any filters will currently cause the request to always fail, as simply
  # searching across users is disabled on speedrun.com's side.
  #
  # NOTE: When using *lookup* all other filters are disabled.
  #
  # NOTE: All search parameters are case-insensitive.
  def self.find_by(lookup : String? = nil,
                   name : String? = nil,
                   twitch : String? = nil,
                   hitbox : String? = nil,
                   twitter : String? = nil,
                   speedrunslive : String? = nil,
                   order_by : String? = nil,
                   sort_direction : String? = nil,
                   page_size : Int32 = 200) : PageIterator(User)
    options = Hash(String, String).new
    if lookup && (name || twitch || hitbox || twitter || speedrunslive)
      Log.warn { "[/users] When `lookup` is used all other search parameters are disabled." }
    end

    options["lookup"] = URI.encode(lookup) if lookup
    options["name"] = URI.encode(name) if name
    options["twitch"] = URI.encode(twitch) if twitch
    options["hitbox"] = URI.encode(hitbox) if hitbox
    options["twitter"] = URI.encode(twitter) if twitter
    options["speedrunslive"] = URI.encode(speedrunslive) if speedrunslive

    order = case order_by
            when Nil
              # Do nothing
            when "name_jap", "namejap", "name-jap", "name.jap"
              "name.jap"
            when "name_int", "nameint", "name-int", "name.int"
              "name.int"
            when "signup", "role"
              order_by
            else
              Log.warn { %([/users] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "signup", and "role". Defaulting to "name.int".) }
              "name.int"
            end

    if order
      options["orderby"] = order

      if sort_direction == "desc"
        options["direction"] = "desc"
      else
        options["direction"] = "asc"
      end
    end

    if page_size > 200
      page_size = 200
      Log.warn { "[/users] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_users(options)
  end

  # Finds a `User` by the given *id* or user name.
  def self.find_by_id(id : String) : Srcom::User
    id = URI.encode(id)

    return User.from_json(request_single_user(id).to_json)
  end

  # Gets the personal bests of the `User` with the given *id*, where *id* can be either a real ID
  # or a username.
  #
  # Providing *top* will only return runs of rank *top* or better.
  #
  # If *series* or *game* are given, only runs done in that `Series` / `Game` are returned. Both
  # of these can be provided as a real ID or their respective abbreviation.
  def self.get_pbs(id : String, top : Int32? = nil, series : String? = nil, game : String? = nil) : Array(Srcom::PBRun)
    options = Hash(String, String).new
    options["top"] = top.to_s if top
    options["series"] = URI.encode(series) if series
    options["game"] = URI.encode(game) if game

    return request_pbs(id, options).map { |raw| PBRun.from_json(raw.to_json) }
  end

  protected def self.request_users(options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}users?#{params}"

    data, next_page_uri = Api.request("/users", url, "GET")
    elements = data.map { |raw| User.from_json(raw.to_json) }
    return PageIterator(User).new(
      endpoint: "/users",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_user(id : String)
    url = "#{BASE_URL}users/#{id}"

    return Api.request_single_item("/users/#{id}", url, "GET")
  end

  protected def self.request_pbs(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}users/#{id}/personal-bests?embed=game,category.variables,category.game,level.categories.variables,level.variables,level.categories.game,players,region,platform&#{params}"

    elements, _next = Api.request("/users/#{id}/personal-bests", url, "GET")
    return elements
  end
end
