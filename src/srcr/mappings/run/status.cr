# If the `#status` is "rejected" then `#reason` will always be present.
struct Srcom::Run::Status
  include JSON::Serializable

  property status : String
  property examiner : String?
  @[JSON::Field(key: "verify-date")]
  property verify_date : Time?
  property reason : String?
end
