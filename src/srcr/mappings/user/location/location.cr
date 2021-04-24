struct Srcom::User::Location
  include JSON::Serializable

  property country : User::Country
  property region : User::Region?
end
