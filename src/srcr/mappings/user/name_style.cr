struct Srcom::User::NameStyle
  include JSON::Serializable

  property style : String
  # light => hexcode and dark => hexcode
  property color : Hash(String, String)?
  # light => hexcode and dark => hexcode
  property color_from : Hash(String, String)?
  # light => hexcode and dark => hexcode
  property color_to : Hash(String, String)?
end
