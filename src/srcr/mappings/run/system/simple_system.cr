struct Srcom::Run::SimpleSystem
  include JSON::Serializable

  property platform : String?
  property emulated : Bool
  property region : String?
end
