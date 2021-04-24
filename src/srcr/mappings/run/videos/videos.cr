struct Srcom::Run::Videos
  include JSON::Serializable

  property text : String?
  property links : Array(Run::Videos::Link)?
end
