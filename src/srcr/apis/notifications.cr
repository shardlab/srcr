class Srcom::Api::Notifications
  # Gets the `Notification`s for the user authenticated with the given *api_key*.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "desc" being the default.
  def self.get(api_key : String,
               sort_direction : String? = nil,
               page_size : Int32 = 200) : PageIterator(Notification)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key

    direction = sort_direction == "asc" ? "asc" : "desc"
    return request_notifications(direction, headers, page_size)
  end

  protected def self.request_notifications(direction : String, headers : HTTP::Headers, page_size : Int32)
    url = "#{BASE_URL}notifications?direction=#{direction}&max=#{page_size}"

    data, next_page_uri = Api.request("/notifications", url, "GET", headers)
    elements = data.map { |raw| Notification.from_json(raw.to_json) }
    return PageIterator(Notification).new(
      endpoint: "/notifications",
      method: "GET",
      headers: headers,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end
end
