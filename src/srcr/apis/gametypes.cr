class Srcom::Api::Gametypes
  # Gets all gametypes.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 20) : Array(Game::Gametype)
    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_gametypes(direction, all_pages, max_results_per_page).map { |raw| Game::Gametype.from_json(raw.to_json) }
  end

  # Gets a `Gametype` by its ID.
  def self.find_by_id(id : String) : Srcom::Game::Gametype
    id = URI.encode(id)

    return Game::Gametype.from_json(request_single_region(id).to_json)
  end

  protected def self.request_gametypes(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}gametypes?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/gametypes", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}gametypes/#{id}"

    return Api.request_single_item("/gametypes/#{id}", url, "GET")
  end
end
