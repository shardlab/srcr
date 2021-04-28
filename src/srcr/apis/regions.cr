class Srcom::Api::Regions
  Log = Srcom::Log.for("regions")

  # Gets all regions.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Region)
    if page_size > 200
      page_size = 200
      Log.warn { "[/regions] Only up to 200 results per page are supported. Request adjusted." }
    end

    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_regions(direction, page_size)
  end

  # Gets a `Region` by their *id*.
  def self.find_by_id(id : String) : Srcom::Region
    id = URI.encode(id)

    return Region.from_json(request_single_region(id).to_json)
  end

  protected def self.request_regions(direction : String, page_size : Int32)
    url = "#{BASE_URL}regions?max=#{page_size}&direction=#{direction}"

    data, next_page_uri = Api.request("/regions", url, "GET")
    elements = data.map { |raw| Region.from_json(raw.to_json) }
    return PageIterator(Region).new(
      endpoint: "/regions",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}regions/#{id}"

    return Api.request_single_item("/regions/#{id}", url, "GET")
  end
end
