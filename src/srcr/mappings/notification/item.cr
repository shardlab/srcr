struct Srcom::Notification::Item
  include JSON::Serializable

  property rel : String
  property uri : String
end
