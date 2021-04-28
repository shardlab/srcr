class Srcom::Api::Gametypes
  Log = Srcom::Log.for("gametypes")

  # Gets all gametypes.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Game::Gametype)
    if page_size > 200
      page_size = 200
      Log.warn { "[/gametypes] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_gametypes(direction, page_size)
  end

  # Gets a `Game::Gametype` by their *id*.
  def self.find_by_id(id : String) : Srcom::Game::Gametype
    id = URI.encode(id)

    return Game::Gametype.from_json(request_single_gametype(id).to_json)
  end

  protected def self.request_gametypes(direction : String, page_size : Int32)
    url = "#{BASE_URL}gametypes?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/gametypes", url, "GET")
    elements = data.map { |raw| Game::Gametype.from_json(raw.to_json) }
    return PageIterator(Game::Gametype).new(
      endpoint: "/gametypes",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_gametype(id : String)
    url = "#{BASE_URL}gametypes/#{id}"

    return Api.request_single_item("/gametypes/#{id}", url, "GET")
  end
end
