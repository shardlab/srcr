class Srcom::Api::Developers
  # Gets all developers.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 200) : Array(Developer)
    direction = sort_direction == "desc" ? "desc" : "asc"

    return request_developers(direction, all_pages, max_results_per_page).map { |raw| Developer.from_json(raw.to_json) }
  end

  # Gets a `Developer` by their *id*.
  def self.find_by_id(id : String) : Srcom::Developer
    id = URI.encode(id)

    return Developer.from_json(request_single_region(id).to_json)
  end

  protected def self.request_developers(direction : String, all_pages : Bool, max_results_per_page : Int32)
    url = "#{BASE_URL}developers?max=#{max_results_per_page}&direction=#{direction}"

    return Api.request("/developers", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_region(id : String)
    url = "#{BASE_URL}developers/#{id}"

    return Api.request_single_item("/developers/#{id}", url, "GET")
  end
end
