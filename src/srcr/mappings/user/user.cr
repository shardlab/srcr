# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::User
  include JSON::Serializable

  @rel : String? # Present in certain contexts, but never relevant
  property id : String
  property names : User::Name
  property pronouns : String?
  property weblink : String
  @[JSON::Field(key: "name-style")]
  property name_style : User::NameStyle
  property role : String
  property signup : Time
  property location : User::Location?
  property twitch : Hash(String, String)?
  property hitbox : Hash(String, String)?
  property youtube : Hash(String, String)?
  property twitter : Hash(String, String)?
  property speedrunslive : Hash(String, String)?
  property links : Array(Link)

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end

  # Gets all `Run`s completed by this `User`.
  #
  # NOTE: Depending on the `User` this request might take a long time or crash.
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    return Srcom::Api::Runs.find_by(platform: @id, page_size: page_size)
  end

  # Gets all the `Game`s this `User` moderates.
  def games(page_size : Int32 = 20) : Srcom::Api::PageIterator(Game)
    return Srcom::Api::Games.find_by(moderator: @id, page_size: page_size)
  end

  # Gets the personal bests of this `User`.
  #
  # Providing *top* will only return runs of rank *top* or better.
  #
  # If *series* or *game* are given, only runs done in that `Series` / `Game` are returned. Both
  # of these can be provided as a real ID or their respective abbreviation.
  def personal_bests(top : Int32? = nil, series : String? = nil, game : String? = nil) : Array(PBRun)
    return Srcom::Api::Users.get_pbs(@id, top, series, game)
  end

  # :ditto:
  #
  # NOTE: Alias to `#personal_bests`.
  def pbs(top : Int32? = nil, series : String? = nil, game : String? = nil) : Array(PBRun)
    return Srcom::Api::Users.get_pbs(@id, top, series, game)
  end
end
