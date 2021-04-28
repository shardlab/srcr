class Srcom::Api::Games
  Log = Srcom::Log.for("games")

  # Searches through all `Game`s using the given query parameters.
  #
  # Searching by *name* performs a fuzzy search across game names and abbreviations.
  #
  # Seaching by *abbreviation* performs an exact-match search.
  #
  # Searching by *released* restricts to search to games released in that exact year.
  #
  # All other search parameters must be an ID.
  #
  # Possible values for *order_by*: "name.jap", "name.int", "abbreviation", "released", or "created", with the default being "name.int".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # NOTE: Not specifying any filter probably leads to the request eventually crashing, leading to incomplete data.
  # If you need every game and can afford to lose some data per game, consider using `.find_by_bulk` instead.
  #
  # NOTE: Since `Game`s are very large objects this method defaults to a small page size
  # to give the request a reasonable speed.
  def self.find_by(name : String? = nil,
                   abbreviation : String? = nil,
                   released : Int32? = nil,
                   gametype : String? = nil,
                   platform : String? = nil,
                   region : String? = nil,
                   genre : String? = nil,
                   engine : String? = nil,
                   developer : String? = nil,
                   publisher : String? = nil,
                   moderator : String? = nil,
                   order_by : String? = nil,
                   sort_direction : String? = nil,
                   page_size : Int32 = 20) : PageIterator(Game)
    options = Hash(String, String).new
    options["name"] = name if name
    options["abbreviation"] = abbreviation if abbreviation
    options["released"] = released.to_s if released
    options["gametype"] = gametype if gametype
    options["platform"] = platform if platform
    options["region"] = region if region
    options["genre"] = genre if genre
    options["engine"] = engine if engine
    options["developer"] = developer if developer
    options["publisher"] = publisher if publisher
    options["moderator"] = moderator if moderator

    order = case order_by
            when Nil
              # Do nothing
            when "name_jap", "namejap", "name-jap", "name.jap"
              "name.jap"
            when "name_int", "nameint", "name-int", "name.int"
              "name.int"
            when "abbreviation", "released", "created"
              order_by
            else
              Log.warn { %([/games] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", "released", and "created". Defaulting to "name.int".) }
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
      Log.warn { "[/games] Only up to 200 results per page in non bulk request are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_games(options)
  end

  # Searches through all `Game`s using the given query parameters, returning `BulkGame`s,
  # which have a greatly reduced amount of data present.
  #
  # Searching by *name* performs a fuzzy search across game names and abbreviations.
  #
  # Seaching by *abbreviation* performs an exact-match search.
  #
  # Searching by *released* restricts to search to games released in that exact year.
  #
  # All other search parameters must be an ID.
  #
  # Possible values for *order_by*: "name.jap", "name.int", "abbreviation", "released", or "created", with the default being "name.int".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # NOTE: As opposed to `.find_by` it is very much feasible to get every game on speedrun.com
  # with this method.
  def self.find_by_bulk(name : String? = nil,
                        abbreviation : String? = nil,
                        released : Int32? = nil,
                        gametype : String? = nil,
                        platform : String? = nil,
                        region : String? = nil,
                        genre : String? = nil,
                        engine : String? = nil,
                        developer : String? = nil,
                        publisher : String? = nil,
                        moderator : String? = nil,
                        order_by : String? = nil,
                        sort_direction : String? = nil,
                        page_size : Int32 = 1000) : PageIterator(BulkGame)
    options = Hash(String, String).new
    options["name"] = name if name
    options["abbreviation"] = abbreviation if abbreviation
    options["released"] = released.to_s if released
    options["gametype"] = gametype if gametype
    options["platform"] = platform if platform
    options["region"] = region if region
    options["genre"] = genre if genre
    options["engine"] = engine if engine
    options["developer"] = developer if developer
    options["publisher"] = publisher if publisher
    options["moderator"] = moderator if moderator

    order = case order_by
            when Nil
              # Do nothing
            when "name_jap", "namejap", "name-jap", "name.jap"
              "name.jap"
            when "name_int", "nameint", "name-int", "name.int"
              "name.int"
            when "abbreviation", "released", "created"
              order_by
            else
              Log.warn { %([/games?_bulk=true] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", "released", and "created". Defaulting to "name.int".) }
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

    if page_size > 1000
      page_size = 1000
      Log.warn { "[/games?_bulk=true] Only up to 1000 results per page in bulk request are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_games_bulk(options)
  end

  # Finds a `Game` given its *id* or abbreviation.
  def self.find_by_id(id : String) : Srcom::Game
    id = URI.encode(id)
    return Game.from_json(request_single_game(id).to_json)
  end

  # Gets the categories belonging to the `Game` given by its *id* or abbreviation.
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
              Log.warn { %([/games/<id>/categories] Unsupported sorting option "#{order_by}". Valid options are "name", "miscellaneous", and "pos". Defaulting to "pos".) }
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

    return request_game_categories(id, options).map { |category| Category.from_json(category.to_json) }
  end

  # Gets the `Level`s belonging to the `Game` given by its *id* or abbreviation.
  #
  # Possible values for *order_by*: "name" or "pos", with the default being "pos".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  def self.get_levels(id : String, order_by : String? = nil, sort_direction : String? = nil) : Array(Level)
    id = URI.encode(id)

    options = Hash(String, String).new

    order = case order_by
            when Nil
              # Do nothing
            when "name", "pos"
              order_by
            else
              Log.warn { %([/games/<id>/levels] Unsupported sorting option "#{order_by}". Valid options are "name", "miscellaneous", and "pos". Defaulting to "pos".) }
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

    return request_game_levels(id, options).map { |level| Level.from_json(level.to_json) }
  end

  # Gets the `Variable`s belonging to the `Game` given by its *id* or abbreviation.
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
              Log.warn { %([/games/<id>/variables] Unsupported sorting option "#{order_by}". Valid options are "name", "mandatory", "user-defined", and "pos". Defaulting to "pos".) }
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

    return request_game_variables(id, options).map { |variable| Variable.from_json(variable.to_json) }
  end

  # Searches through all the derived games of the `Game` given by its *id* or abbreviation
  # using the given query parameters (and gets all derived games if none of the filters are used).
  #
  # Searching by *name* performs a fuzzy search across game names and abbreviations.
  #
  # Seaching by *abbreviation* performs an exact-match search.
  #
  # Searching by *released* restricts to search to games released in that exact year.
  #
  # All other search parameters must be an ID.
  #
  # Possible values for *order_by*: "name.jap", "name.int", "abbreviation", "released", or "created", with the default being "name.int".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  #
  # NOTE: Since `Game`s typically don't have too many derived games it is very much feasible to get
  # everything here.
  def self.get_derived_games(id : String,
                             name : String? = nil,
                             abbreviation : String? = nil,
                             released : Int32? = nil,
                             gametype : String? = nil,
                             platform : String? = nil,
                             region : String? = nil,
                             genre : String? = nil,
                             engine : String? = nil,
                             developer : String? = nil,
                             publisher : String? = nil,
                             moderator : String? = nil,
                             order_by : String? = nil,
                             sort_direction : String? = nil,
                             page_size : Int32 = 200) : PageIterator(Game)
    options = Hash(String, String).new
    options["name"] = name if name
    options["abbreviation"] = abbreviation if abbreviation
    options["released"] = released.to_s if released
    options["gametype"] = gametype if gametype
    options["platform"] = platform if platform
    options["region"] = region if region
    options["genre"] = genre if genre
    options["engine"] = engine if engine
    options["developer"] = developer if developer
    options["publisher"] = publisher if publisher
    options["moderator"] = moderator if moderator

    order = case order_by
            when Nil
              # Do nothing
            when "name_jap", "namejap", "name-jap", "name.jap"
              "name.jap"
            when "name_int", "nameint", "name-int", "name.int"
              "name.int"
            when "abbreviation", "released", "created"
              order_by
            else
              Log.warn { %([/games/<id>/derived-games] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", "released", and "created". Defaulting to "name.int".) }
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
      Log.warn { "[/games/#{id}/derived-games] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_derived_games(id, options)
  end

  # Gets every `Leaderboard` with the *top* N runs for the `Game` given by its *id* or abbreviation,
  # skipping over empty `Leaderboard`s if *skip_empty* is `true`.
  #
  # If *miscellaneous* is set to `false`, only `Leaderboard`s for non-miscellaneous categories will
  # be returned. If it is set to `true` `Leaderboard`s for both miscellaneous and non-miscellaneous
  # categories will be returned.
  #
  # NOTE: This can result in more than N runs per `Leaderboard`, as ties can occur.
  def self.get_records(id : String,
                       top : Int32 = 3,
                       scope : String? = nil,
                       miscellaneous : Bool = true,
                       skip_empty : Bool = false,
                       page_size : Int32 = 200) : PageIterator(Leaderboard)
    options = Hash(String, String).new
    options["top"] = top.to_s
    case scope
    when Nil
      # Do nothing
    when "levels", "all"
      options["scope"] = scope
    when "full-game", "full_game"
      options["scope"] = "full-game"
    else
      Log.warn { %([/games/<id>/recrods] Unsupported scope "#{scope}". Valid options are "levels", "all", and "full-game". Defaulting to "all".) }
      options["scope"] = "all"
    end

    options["miscellaneous"] = miscellaneous.to_s
    options["skip-empty"] = skip_empty.to_s

    if page_size > 200
      page_size = 200
      Log.warn { "[/games/#{id}/records] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_game_records(id, options)
  end

  protected def self.request_games(options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games?embed=gametypes,moderators,platforms,regions,genres,engines,developers,publishers,categories.variables,categories.game,variables,levels.categories.variables,levels.variables,levels.categories.game&#{params}"

    data, next_page_uri = Api.request("/games", url, "GET")
    elements = data.map { |raw| Game.from_json(raw.to_json) }
    return PageIterator(Game).new(
      endpoint: "/games",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_games_bulk(options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games?_bulk=true&#{params}"

    data, next_page_uri = Api.request("/games?_bulk=true", url, "GET")
    elements = data.map { |raw| BulkGame.from_json(raw.to_json) }
    return PageIterator(BulkGame).new(
      endpoint: "/games?_bulk=true",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_game(id : String)
    url = "#{BASE_URL}games/#{id}?embed=gametypes,moderators,platforms,regions,genres,engines,developers,publishers,categories.variables,categories.game,variables,levels.categories.variables,levels.variables,levels.categories.game"

    return Api.request_single_item("/games/#{id}", url, "GET")
  end

  protected def self.request_game_categories(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games/#{id}/categories?embed=variables,game&#{params}"

    elements, _next = Api.request("/games/#{id}/categories", url, "GET")
    return elements
  end

  protected def self.request_game_levels(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games/#{id}/levels?embed=variables,categories.variables,categories.game&#{params}"

    elements, _next = Api.request("/games/#{id}/levels", url, "GET")
    return elements
  end

  protected def self.request_game_variables(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games/#{id}/variables?#{params}"

    elements, _next = Api.request("/games/#{id}/variables", url, "GET")
    return elements
  end

  protected def self.request_derived_games(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games/#{id}/derived-games?embed=gametypes,moderators,platforms,regions,genres,engines,developers,publishers,categories.variables,categories.game,variables,levels.categories.variables,levels.variables,levels.categories.game&#{params}"

    data, next_page_uri = Api.request("/games/#{id}/derived-games", url, "GET")
    elements = data.map { |raw| Game.from_json(raw.to_json) }
    return PageIterator(Game).new(
      endpoint: "/games/#{id}/derived-games",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_game_records(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}games/#{id}/records?embed=game,category.variables,category.game,level.categories.variables,level.categories.game,level.variables,players,regions,platforms,variables&#{params}"

    data, next_page_uri = Api.request("/games/#{id}/records", url, "GET")
    elements = data.map { |raw| Leaderboard.from_json(raw.to_json) }
    return PageIterator(Leaderboard).new(
      endpoint: "/games/#{id}/records",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end
end
