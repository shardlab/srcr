struct Srcom::PBRun
  include JSON::Serializable

  property place : Int32
  property run : SimpleRun
  @[JSON::Field(root: "data")]
  property game : SimpleGame
  @[JSON::Field(root: "data")]
  property category : Category
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedLevelConverter)]
  property level : Level?
  @[JSON::Field(root: "data")]
  property players : Array(User | Guest)
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedRegionConverter)]
  property region : Region?
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedPlatformConverter)]
  property platform : Platform?

  # Returns the full `Game` this run was played in.
  def full_game : Game
    return Srcom::Api::Games.find_by_id(@game.id)
  end
end
