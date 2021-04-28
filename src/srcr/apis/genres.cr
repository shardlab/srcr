class Srcom::Api::Genres
  Log = Srcom::Log.for("genres")

  # Gets all genres.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Genre)
    if page_size > 200
      page_size = 200
      Log.warn { "[/genres] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_genres(direction, page_size)
  end

  # Gets a `Genre` by their *id*.
  def self.find_by_id(id : String) : Srcom::Genre
    id = URI.encode(id)

    return Genre.from_json(request_single_genre(id).to_json)
  end

  protected def self.request_genres(direction : String, page_size : Int32)
    url = "#{BASE_URL}genres?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/genres", url, "GET")
    elements = data.map { |raw| Genre.from_json(raw.to_json) }
    return PageIterator(Genre).new(
      endpoint: "/genres",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_genre(id : String)
    url = "#{BASE_URL}genres/#{id}"

    return Api.request_single_item("/genres/#{id}", url, "GET")
  end
end
