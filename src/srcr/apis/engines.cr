class Srcom::Api::Engines
  # Gets all engines.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 20) : Array(Engine)
    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_gametypes(direction, all_pages, max_results_per_page).map { |raw| Engine.from_json(raw.to_json) }
  end

  # Gets an `Engine` by its ID.
  def self.find_by_id(id : String) : Srcom::Engine
    id = URI.encode(id)

    return Engine.from_json(request_single_region(id).to_json)
  end

  protected def self.request_gametypes(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}engines?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/engines", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}engines/#{id}"

    return Api.request_single_item("/engines/#{id}", url, "GET")
  end
end
