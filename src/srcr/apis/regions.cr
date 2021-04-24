class Srcom::Api::Regions
  # Gets all regions.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 20) : Array(Region)
    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_regions(direction, all_pages, max_results_per_page).map { |raw| Region.from_json(raw.to_json) }
  end

  # Gets a `Region` given its *id*.
  def self.find_by_id(id : String) : Srcom::Region
    id = URI.encode(id)

    return Region.from_json(request_single_region(id).to_json)
  end

  protected def self.request_regions(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}regions?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/regions", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}regions/#{id}"

    return Api.request_single_item("/regions/#{id}", url, "GET")
  end
end
