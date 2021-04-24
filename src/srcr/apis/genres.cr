class Srcom::Api::Genres
  # Gets all genres.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 20) : Array(Genre)
    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_gametypes(direction, all_pages, max_results_per_page).map { |raw| Genre.from_json(raw.to_json) }
  end

  # Gets a `Genre` by its *id*.
  def self.find_by_id(id : String) : Srcom::Genre
    id = URI.encode(id)

    return Genre.from_json(request_single_region(id).to_json)
  end

  protected def self.request_gametypes(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}genres?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/genres", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}genres/#{id}"

    return Api.request_single_item("/genres/#{id}", url, "GET")
  end
end
