struct Srcom::Game::Name
  include JSON::Serializable

  property international : String
  property japanese : String?
  property twitch : String?
end
