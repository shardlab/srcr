# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Run
  include JSON::Serializable

  property id : String
  property weblink : String
  @[JSON::Field(root: "data")]
  property game : SimpleGame
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedLevelConverter)]
  property level : Level?
  # Category is not supposed to be nilable, but unfortunately when embedded this is not true.
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedCategoryConverter)]
  property category : Category?
  property videos : Run::Videos?
  property comment : String?
  property status : Run::Status
  @[JSON::Field(root: "data")]
  property players : Array(User | Guest)
  @[JSON::Field(converter: Time::Format.new("%F"))]
  property date : Time?
  property submitted : Time?
  property times : Run::Times
  property system : Run::SimpleSystem
  property splits : Run::Splits?
  property values : Hash(String, String)
  property links : Array(Link)
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedRegionConverter)]
  property region : Region?
  @[JSON::Field(root: "data", converter: Srcom::EmbeddedPlatformConverter)]
  property platform : Platform?

  # Gets the full `Game` this `Run` was played in.
  def full_game : Game
    return Srcom::Api::Games.find_by_id(@game.id)
  end

  # Gets the full `User` for the person who examined this `Run`, if it was already examined.
  def examiner : User?
    id = @status.examiner
    return id ? Srcom::Api::Users.find_by_id(id) : nil
  end
end
