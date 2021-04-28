class Srcom::Api::Engines
  Log = Srcom::Log.for("engines")

  # Gets all engines.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Engine)
    if page_size > 200
      page_size = 200
      Log.warn { "[/engines] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_engines(direction, page_size)
  end

  # Gets an `Engine` by its ID.
  def self.find_by_id(id : String) : Srcom::Engine
    id = URI.encode(id)

    return Engine.from_json(request_single_engine(id).to_json)
  end

  protected def self.request_engines(direction : String, page_size : Int32)
    url = "#{BASE_URL}engines?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/engines", url, "GET")
    elements = data.map { |raw| Engine.from_json(raw.to_json) }
    return PageIterator(Engine).new(
      endpoint: "/engines",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_engine(id : String)
    url = "#{BASE_URL}engines/#{id}"

    return Api.request_single_item("/engines/#{id}", url, "GET")
  end
end
