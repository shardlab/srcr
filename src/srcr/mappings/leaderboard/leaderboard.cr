# NOTE: The only `Link` in `#links` leads to the `Category` of this `Leaderboard`, which is already embedded.
struct Srcom::Leaderboard
  include JSON::Serializable

  property weblink : String
  @[JSON::Field(root: "data")]
  property game : SimpleGame
  @[JSON::Field(root: "data")]
  property category : Category
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedLevelConverter)]
  property level : Level?
  property platform : String?
  property region : String?
  property emulators : Bool?
  @[JSON::Field(key: "video-only")]
  property video_only : Bool
  property timing : String?
  # Variable ID -> Value ID
  property values : Hash(String, String)
  property runs : Array(LeaderboardRun)
  property links : Array(Link)
  @[JSON::Field(root: "data")]
  property players : Array(User | Guest)
  @[JSON::Field(root: "data")]
  property regions : Array(Region)
  @[JSON::Field(root: "data")]
  property platforms : Array(Platform)
  @[JSON::Field(root: "data")]
  property variables : Array(Variable)
end
