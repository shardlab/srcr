struct Srcom::Game::Asset
  include JSON::Serializable

  property uri : String
  property width : Int32
  property height : Int32
end
