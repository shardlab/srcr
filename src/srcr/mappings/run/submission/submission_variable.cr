struct Srcom::Run::Submission::Variable
  include JSON::Serializable

  property type : String
  property value : String

  # If the *type* is "user-defined" the *value* is whatever the user has defined; if the *type*
  # is *pre-defined* the *value* must be the ID of the `Variable::Values::Value` used.
  def initialize(type : String, @value : String)
    if type == "user-defined" || "type" == "pre-defined"
      @type = type
    else
      raise %(Srcom::Run::Submission::Variable must have a type of either "user-defined" or "pre-defined".)
    end
  end
end
