class Srcom::Api::Profile
  # Gets the profile (as a full `User` object) of the user authenticated with the given *api_key*.
  def self.get(api_key : String) : Srcom::User
    headers = HTTP::Headers.new
    headers["X-API-Key"] = api_key

    return User.from_json(request_profile(headers).to_json)
  end

  protected def self.request_profile(headers : HTTP::Headers)
    url = "#{BASE_URL}profile"

    return Api.request_single_item("/profile", url, "GET", headers)
  end
end
