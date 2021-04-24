struct Srcom::Game::Ruleset
  include JSON::Serializable

  @[JSON::Field(key: "show-milliseconds")]
  property show_milliseconds : Bool
  @[JSON::Field(key: "require-verification")]
  property require_verification : Bool
  @[JSON::Field(key: "require-video")]
  property require_video : Bool
  @[JSON::Field(key: "run-times")]
  property run_times : Array(String)
  @[JSON::Field(key: "default-time")]
  property default_time : String
  @[JSON::Field(key: "emulators-allowed")]
  property emulators_allowed : Bool
end
