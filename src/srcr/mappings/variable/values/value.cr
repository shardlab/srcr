struct Srcom::Variable::Values::Value
  include JSON::Serializable

  property label : String
  property rules : String?
  # Right now the only defined flag is `miscellaneous`, which can be `true`, `false`, or `nil`.
  property flags : Hash(String, Bool?)?
end
