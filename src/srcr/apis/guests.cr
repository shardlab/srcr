class Srcom::Api::Guests
  # Gets a `Guest` given their *name*.
  def self.find_by_name(name : String) : Srcom::Guest
    name = URI.encode(name)

    return Guest.from_json(request_guest(name).to_json)
  end

  protected def self.request_guest(name : String)
    url = "#{BASE_URL}guests/#{name}"

    return Api.request_single_item("/guests/#{name}", url, "GET")
  end
end
