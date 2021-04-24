struct Srcom::Variable::Values
  include JSON::Serializable

  @[Deprecated]
  property _note : String?
  @[Deprecated]
  property choices : Hash(String, String)?
  # Value ID => Value
  property values : Hash(String, Variable::Values::Value)
  property default : String?
end
