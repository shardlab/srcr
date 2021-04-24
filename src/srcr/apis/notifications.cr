class Srcom::Api::Notifications
  # Gets the `Notification`s for the user authenticated with the given *api_key*.
  #
  # Possible values for *sort_direction*: "desc" or "asc", with "desc" being the default.
  def self.get(api_key : String,
               sort_direction : String? = nil,
               all_pages : Bool = false,
               max_results_per_page : Int32 = 20) : Array(Notification)
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key

    direction = sort_direction == "asc" ? "asc" : "desc"
    return request_notifications(direction, headers, all_pages, max_results_per_page).map { |raw| Notification.from_json(raw.to_json) }
  end

  protected def self.request_notifications(direction : String,
                                           headers : HTTP::Headers,
                                           all_pages : Bool,
                                           max_results_per_page : Int32)
    url = "#{BASE_URL}notifications?direction=#{direction}&max=#{max_results_per_page}"
    Api.request("/notifications", url, "GET", headers, all_pages: false)
  end
end
