class Srcom::Api::Publishers
  Log = Srcom::Log.for("publishers")

  # Gets all publishers.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Publisher)
    if page_size > 200
      page_size = 200
      Log.warn { "[/publishers] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_publishers(direction, page_size)
  end

  # Gets a `Publisher` by their *id*.
  def self.find_by_id(id : String) : Srcom::Publisher
    id = URI.encode(id)

    return Publisher.from_json(request_single_publisher(id).to_json)
  end

  protected def self.request_publishers(direction : String, page_size : Int32)
    url = "#{BASE_URL}publishers?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/publishers", url, "GET")
    elements = data.map { |raw| Publisher.from_json(raw.to_json) }
    return PageIterator(Publisher).new(
      endpoint: "/publishers",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_publisher(id : String)
    url = "#{BASE_URL}publishers/#{id}"

    return Api.request_single_item("/publishers/#{id}", url, "GET")
  end
end
