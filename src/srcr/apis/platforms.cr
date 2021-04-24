class Srcom::Api::Platforms
  Log = Srcom::Log.for("platforms")

  # Gets all platforms.
  #
  # Possible values for *order_by*: "released" or "name", with the default being "name".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(order_by : String? = nil,
               sort_direction : String? = nil,
               all_pages : Bool = true,
               max_results_per_page : Int32 = 200) : Array(Platform)
    options = Hash(String, String).new
    case order_by
    when Nil
      # Do nothing
    when "released", "name"
      options["orderby"] = order_by
    else
      Log.warn { %([/platforms] Unsupported sorting option "#{order_by}". Valid options are "released" and "name". Defaulting to "name".) }
      options["orderby"] = "name"
    end
    options["direction"] = sort_direction == "desc" ? "desc" : "asc"

    if max_results_per_page > 200
      max_results_per_page = 200
      Log.warn { "[/platforms] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = max_results_per_page.to_s

    return request_platforms(options, all_pages).map { |raw| Platform.from_json(raw.to_json) }
  end

  # Gets a `Platform` by its *id*.
  def self.find_by_id(id : String) : Srcom::Platform
    id = URI.encode(id)

    return Platform.from_json(request_single_platform(id).to_json)
  end

  protected def self.request_platforms(options : Hash(String, String), all_pages : Bool)
    params = URI::Params.encode(options)
    url = "#{BASE_URL}platforms?#{params}"

    return Api.request("/platforms", url, "GET", all_pages: all_pages)
  end

  protected def self.request_single_platform(id : String)
    url = "#{BASE_URL}platforms/#{id}"

    return Api.request_single_item("/platforms/#{id}", url, "GET")
  end
end
