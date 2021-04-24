struct Srcom::BulkGame::Name
  include JSON::Serializable

  property international : String
  property japanese : String?
end
