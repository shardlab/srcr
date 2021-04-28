class Srcom::Api::Platforms
  Log = Srcom::Log.for("platforms")

  # Gets all platforms.
  #
  # Possible values for *order_by*: "released" or "name", with the default being "name".
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get(order_by : String? = nil, sort_direction : String? = nil, page_size : Int32 = 200) : PageIterator(Platform)
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

    if page_size > 200
      page_size = 200
      Log.warn { "[/platforms] Only up to 200 results per page are supported. Request adjusted." }
    end

    options["max"] = page_size.to_s

    return request_platforms(options)
  end

  # Gets a `Platform` by its *id*.
  def self.find_by_id(id : String) : Srcom::Platform
    id = URI.encode(id)

    return Platform.from_json(request_single_platform(id).to_json)
  end

  protected def self.request_platforms(options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}platforms?#{params}"

    data, next_page_uri = Api.request("/platforms", url, "GET")
    elements = data.map { |raw| Platform.from_json(raw.to_json) }
    return PageIterator(Platform).new(
      endpoint: "/platforms",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end

  protected def self.request_single_platform(id : String)
    url = "#{BASE_URL}platforms/#{id}"

    return Api.request_single_item("/platforms/#{id}", url, "GET")
  end
end
