# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
# Also has shorthand methods to get all the full resources for things that didn't get embedded.
struct Srcom::SimpleRun
  include JSON::Serializable

  property id : String
  property weblink : String
  property game : String
  property level : String?
  property category : String
  property videos : Run::Videos?
  property comment : String?
  property status : Run::Status
  property players : Array(SimplePlayer)
  @[JSON::Field(converter: Time::Format.new("%F"))]
  property date : Time?
  property submitted : Time?
  property times : Run::Times
  property system : Run::SimpleSystem
  property splits : Run::Splits?
  property values : Hash(String, String)

  # Gets the full `Run` resource with everything embedded.
  def full_run : Run
    return Srcom::Api::Runs.find_by_id(@id)
  end

  # Gets all the players that played this run as either a full `User` or `Guest` object.
  #
  # NOTE: Since there's a bug with `Guest`s sometimes not having a name, those entries will be
  # skipped.
  def full_players : Array(User | Guest)
    players = Array(User | Guest).new
    @players.each do |player|
      if player.rel == "user"
        players << Srcom::Api::Users.find_by_id(player.id.not_nil!)
      else
        # Guests without a name is one of the weird things that can happen, unfortunately.
        players << Srcom::Api::Guests.find_by_name(player.name) if player.name
      end
    end

    return players
  end

  # Gets the full `Platform` this run was played on, if provided.
  def platform : Platform?
    id = @system.platform
    return Srcom::Api::Platforms.find_by_id(id) if id
  end

  # Gets the full `Region` this run was played in, if provided.
  def region : Region?
    id = @system.region
    return Srcom::Api::Region.find_by_id(id) if id
  end

  # Gets the full `Game` this `Run` was played in.
  def full_game : Game
    return Srcom::Api::Games.find_by_id(@game.id)
  end

  # Gets the full `Level` this `Run` was played in.
  def full_level : Level?
    id = @level
    return Srcom::Api::Levels.find_by_id(id) if id
  end

  # Gets the full `Category` this `Run` was played in.
  def full_category : Category
    return Srcom::Api::Categories.find_by_id(@category)
  end

  # Gets the full `User` for the person who examined this `Run`, if it was already examined.
  def examiner : User?
    id = @status.examiner
    return Srcom::Api::Users.find_by_id(id) if id
  end
end
