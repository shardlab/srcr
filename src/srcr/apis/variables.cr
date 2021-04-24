class Srcom::Api::Variables
  # Finds a `Variable` given its *id*.
  def self.find_by_id(id : String) : Srcom::Variable
    id = URI.encode(id)

    return Variable.from_json(request_single_variable(id).to_json)
  end

  protected def self.request_single_variable(id : String)
    url = "#{BASE_URL}variables/#{id}"

    return Api.request_single_item("/variables/#{id}", url, "GET")
  end
end
