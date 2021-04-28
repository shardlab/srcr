# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
# Does not cover the `Link` to get the applicable `Level`s, `Category`s, or `Variable`s,
# since those are already embedded.
#
# NOTE: Also does not cover romhacks, since the endpoint is deprecated and synonymous with derived-games.
struct Srcom::Game
  include JSON::Serializable

  property id : String
  property names : Game::Name
  property abbreviation : String
  property weblink : String
  property released : Int32
  @[JSON::Field(key: "release-date", converter: Time::Format.new("%F"))]
  property release_date : Time
  property ruleset : Game::Ruleset
  property romhack : Bool
  @[JSON::Field(root: "data")]
  property gametypes : Array(Game::Gametype)
  @[JSON::Field(root: "data")]
  property platforms : Array(Platform)
  @[JSON::Field(root: "data")]
  property regions : Array(Region)
  @[JSON::Field(root: "data")]
  property genres : Array(Genre)
  @[JSON::Field(root: "data")]
  property engines : Array(Engine)
  @[JSON::Field(root: "data")]
  property developers : Array(Developer)
  @[JSON::Field(root: "data")]
  property publishers : Array(Publisher)
  @[JSON::Field(root: "data")]
  property moderators : Array(User)
  property created : Time?
  property assets : Game::Assets
  property links : Array(Link)
  @[JSON::Field(root: "data")]
  property levels : Array(Level)
  @[JSON::Field(root: "data")]
  property categories : Array(Category)
  @[JSON::Field(root: "data")]
  property variables : Array(Variable)

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end

  # Gets all `Run`s completed in this `Game`.
  #
  # Defaults to getting all of them since there shouldn't be an absurd amount of `Run´s in
  # a single `Game`.
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    Srcom::Api::Runs.find_by(game: @id, page_size: page_size)
  end

  # Gets every `Leaderboard` with the *top* N runs for this `Game`, skipping over empty
  # `Leaderboard`s if *skip_empty* is `true`.
  #
  # If *miscellaneous* is set to `false`, only `Leaderboard`s for non-miscellaneous categories will
  # be returned. If it is set to `true` `Leaderboard`s for both miscellaneous and non-miscellaneous
  # categories will be returned.
  #
  # This method defaults to getting everything, as it is doubtful a single `Game` will have
  # truly that many `Leaderboard`s.
  #
  # NOTE: This can result in more than N runs per `Leaderboard`, as ties can occur.
  def records(top : Int32 = 3,
              scope : String = "all",
              miscellaneous : Bool = true,
              skip_empty : Bool = false,
              page_size : Int32 = 200) : Srcom::Api::PageIterator(Leaderboard)
    Srcom::Api::Games.get_records(@id, top, scope, miscellaneous, skip_empty, page_size)
  end

  # Gets all the `Series` this `Game` belongs to, if it belongs to any.
  #
  # NOTE: It is both possible for a game to not be part of a `Series`, and for it to be part of several.
  def series : Array(Series)
    series = Array(Series).new
    @links.select { |link| link.rel == "series" }.each do |link|
      id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
      series << Srcom::Api::Series.find_by_id(id)
    end

    return series
  end

  # Returns the `Game` this `Game` is derived from, if it is a derived game.
  def base_game : Game?
    if (link = @links.find { |l| l.rel == "base-game" })
      id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
      return Srcom::Api::Games.find_by_id(id)
    else
      # This game doesn't have a base game
      return nil
    end
  end

  # Returns all `Game`s derived from this `Game`.
  def derived_games(page_size : Int32 = 200) : Srcom::Api::PageIterator(Game)
    return Srcom::Api::Games.get_derived_games(@id, page_size: page_size)
  end

  # Returns the `Leaderboard` for the `Category` that is first shown when this `Game` is visited
  # on speedrun.com.
  def leaderboard : Leaderboard
    # The category ID can likely also be found by doing `@categories.first.id`, but I'm not 100%
    # certain that the first category in the array is guaranteed to be the default one for the game
    # so I'd rather make sure to be correct by extracting the ID from the link.
    link = @links.find { |l| l.rel == "leaderboard" }.not_nil!
    category_id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
    return Srcom::Api::Leaderboards.get_full_game_board(game: @id, category: category_id)
  end
end
