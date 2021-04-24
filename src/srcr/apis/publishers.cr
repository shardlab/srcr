class Srcom::Api::Publishers
  # Gets all publishers.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 200) : Array(Publisher)
    direction = sort_direction == "desc" ? "desc" : "asc"

    if max_results_per_page > 200
      max_results_per_page = 200
      Log.warn { "[/publishers] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = max_results_per_page.to_s

    return request_developers(direction, all_pages, max_results_per_page).map { |raw| Publisher.from_json(raw.to_json) }
  end

  # Gets a `Publisher` given their *id*.
  def self.find_by_id(id : String) : Srcom::Publisher
    id = URI.encode(id)

    return Publisher.from_json(request_single_region(id).to_json)
  end

  protected def self.request_developers(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}publishers?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/publishers", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}publishers/#{id}"

    return Api.request_single_item("/publishers/#{id}", url, "GET")
  end
end
