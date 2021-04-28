struct Srcom::Variable::Values
  include JSON::Serializable

  # DEPRECATED: This field is no longer actively used by speedrun.com and only present for legacy purposes
  property _note : String?
  # DEPRECATED: This field is no longer actively used by speedrun.com and only present for legacy purposes
  property choices : Hash(String, String)?
  # Value ID => Value
  property values : Hash(String, Variable::Values::Value)
  property default : String?
end
