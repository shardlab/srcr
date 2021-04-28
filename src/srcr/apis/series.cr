class Srcom::Api::Series
  Log = Srcom::Log.for("series")

  # Searches through all `Series` using the given query parameters.
  #
  # Searching by *name* performs a fuzzy search across series names and abbreviations.
  #
  # Seaching by *abbreviation* performs an exact-match search.
  #
  # Searching by *moderator* will only return `Series` moderated by the `User` with the given id.
  #
  # Possible values for *order_by*: "name.jap", "name.int", "abbreviation", or "created", with the default being "name.int".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with the default being "asc".
  def self.find_by(name : String? = nil,
                   abbreviation : String? = nil,
                   moderator : String? = nil,
                   order_by : String? = nil,
                   sort_direction : String? = nil,
                   page_size : Int32 = 200) : PageIterator(Srcom::Series)
    options = Hash(String, String).new
    options["name"] = URI.encode(name) if name
    options["abbreviation"] = URI.encode(abbreviation) if abbreviation
    options["moderator"] = URI.encode(moderator) if moderator

    order = case order_by
            when "name_jap", "namejap", "name-jap", "name.jap"
              "name.jap"
            when "name_int", "nameint", "name-int", "name.int"
              "name.int"
            when "abbreviation", "created"
              order_by
            else
              Log.warn { %([/series] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", and "created". Defaulting to "name.int".) }
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
      Log.warn { "[/series] Only up to 200 results per page in non bulk request are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    request_series(options)
  end

  # Finds a `Series` given its *id* or abbreviation.
  def self.find_by_id(id : String) : Srcom::Series
    id = URI.encode(id)

    return Srcom::Series.from_json(request_single_series(id).to_json)
  end

  # Searches through all the games in the `Series` given by its *id* or abbreviation
  # using the given query parameters (and gets all of those games if none of the filters are used).
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
  # NOTE: Since `Series` typically don't have too many games in them it is very much feasible to get
  # everything here, but only when requested in smaller chunks, so that is what is defaulted to.
  def self.get_games(id : String,
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
                     page_size : Int32 = 20) : PageIterator(Game)
    options = Hash(String, String).new
    options["name"] = URI.encode(name) if name
    options["abbreviation"] = URI.encode(abbreviation) if abbreviation
    options["released"] = released.to_s if released
    options["gametype"] = URI.encode(gametype) if gametype
    options["platform"] = URI.encode(platform) if platform
    options["region"] = URI.encode(region) if region
    options["genre"] = URI.encode(genre) if genre
    options["engine"] = URI.encode(engine) if engine
    options["developer"] = URI.encode(developer) if developer
    options["publisher"] = URI.encode(publisher) if publisher
    options["moderator"] = URI.encode(moderator) if moderator

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
              Log.warn { %([/series/<id>/games] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", "released", and "created". Defaulting to "name.int".) }
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
      Log.warn { "[/series/<id>/games] Only up to 200 results per page in non bulk request are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_series_games(id, options)
  end

  # Searches through all the games in the `Series` given by its *id* or abbreviation
  # using the given query parameters (and gets all of those games if none of the filters are used),
  # returning `BulkGame`s, which have a greatly reduced amount of data present.
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
  def self.get_games_bulk(id : String,
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
                          page_size : Int32 = 1000) : PageIterator(BulkGame)
    options = Hash(String, String).new
    options["name"] = URI.encode(name) if name
    options["abbreviation"] = URI.encode(abbreviation) if abbreviation
    options["released"] = released.to_s if released
    options["gametype"] = URI.encode(gametype) if gametype
    options["platform"] = URI.encode(platform) if platform
    options["region"] = URI.encode(region) if region
    options["genre"] = URI.encode(genre) if genre
    options["engine"] = URI.encode(engine) if engine
    options["developer"] = URI.encode(developer) if developer
    options["publisher"] = URI.encode(publisher) if publisher
    options["moderator"] = URI.encode(moderator) if moderator

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
              Log.warn { %([/series/<id>/games?_bulk=true] Unsupported sorting option "#{order_by}". Valid options are "name.int", "name.jap", "abbreviation", "released", and "created". Defaulting to "name.int".) }
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
      Log.warn { "[/series/<id>/games?_bulk=true] Only up to 1000 results per page in bulk request are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_series_games_bulk(id, options)
  end

  protected def self.request_series(options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}series?embed=moderators&#{params}"

    data, next_page_uri = Api.request("/series", url, "GET")
    elements = data.map { |raw| Srcom::Series.from_json(raw.to_json) }
    return PageIterator(Srcom::Series).new(
      endpoint: "/series",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_series(id : String)
    url = "#{BASE_URL}series/#{id}?embed=moderators"

    return Api.request_single_item("/series/#{id}", url, "GET")
  end

  protected def self.request_series_games(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}series/#{id}/games?embed=gametypes,moderators,platforms,regions,genres,engines,developers,publishers,categories.variables,categories.game,variables,levels.categories.variables,levels.variables,levels.categories.game&#{params}"

    data, next_page_uri = Api.request("/series/#{id}/games", url, "GET")
    elements = data.map { |raw| Game.from_json(raw.to_json) }
    return PageIterator(Game).new(
      endpoint: "/series/#{id}/games",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_series_games_bulk(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}series/#{id}/games?_bulk=true&#{params}"

    data, next_page_uri = Api.request("/series/#{id}/games?_bulk=true", url, "GET")
    elements = data.map { |raw| BulkGame.from_json(raw.to_json) }
    return PageIterator(BulkGame).new(
      endpoint: "/series/#{id}/games?_bulk=true",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end
end
