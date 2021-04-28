class Srcom::Api::Developers
  Log = Srcom::Log.for("developers")

  # Gets all developers.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Developer)
    if page_size > 200
      page_size = 200
      Log.warn { "[/developers] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_developers(direction, page_size)
  end

  # Gets a `Developer` by their *id*.
  def self.find_by_id(id : String) : Srcom::Developer
    id = URI.encode(id)

    return Developer.from_json(request_single_developer(id).to_json)
  end

  protected def self.request_developers(direction : String, page_size : Int32)
    url = "#{BASE_URL}developers?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/developers", url, "GET")
    elements = data.map { |raw| Developer.from_json(raw.to_json) }
    return PageIterator(Developer).new(
      endpoint: "/developers",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_developer(id : String)
    url = "#{BASE_URL}developers/#{id}"

    return Api.request_single_item("/developers/#{id}", url, "GET")
  end
end
