# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
# Also has shorthand methods to get all the full resources for things that didn't get embedded.
#
# NOTE: Not covering the romhacks link, since it is deprecated and synonymous with derived-games.
struct Srcom::SimpleGame
  include JSON::Serializable

  property id : String
  property names : Game::Name
  property abbreviation : String
  property weblink : String
  property released : Int32
  @[JSON::Field(key: "release-date")]
  property release_date : String
  property ruleset : Game::Ruleset
  property romhack : Bool
  property gametypes : Array(String)
  property platforms : Array(String)
  property regions : Array(String)
  property genres : Array(String)
  property engines : Array(String)
  property developers : Array(String)
  property publishers : Array(String)
  property moderators : Hash(String, String) # ID => "moderator" | "super-moderator"
  property created : Time?
  property assets : Game::Assets
  property links : Array(Link)

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end

  # Gets this `SimpleGame` as a full `Game` with everything embedded.
  def full_game : Game
    return Srcom::Api::Games.find_by_id(@id)
  end

  # Gets the full `Gametype`s applicable to this game.
  def full_gametypes : Array(Gametype)
    gametypes = Array(Gametype).new
    @gametypes.each do |id|
      gametypes << Srcom::Api::Gametypes.find_by_id(id)
    end

    return gametypes
  end

  # Gets the full `Platform`s this game runs on.
  def full_platforms : Array(Platform)
    platforms = Array(Platform).new
    @platforms.each do |id|
      platforms << Srcom::Api::Platforms.find_by_id(id)
    end

    return platforms
  end

  # Gets the full `Region`s this game is available in.
  def full_regions : Array(Region)
    regions = Array(Region).new
    @regions.each do |id|
      regions << Srcom::Api::Regions.find_by_id(id)
    end

    return regions
  end

  # Gets the full `Genre`s this game belongs to.
  def full_genres : Array(Genre)
    genres = Array(Genre).new
    @genres.each do |id|
      genres << Srcom::Api::Genres.find_by_id(id)
    end

    return genres
  end

  # Gets the full `Engine`s this game runs on.
  def full_engines : Array(Engine)
    engines = Array(Engine).new
    @engines.each do |id|
      engines << Srcom::Api::Engines.find_by_id(id)
    end

    return engines
  end

  # Gets the full `Developer`s that developed this game.
  def full_developers : Array(Developer)
    developers = Array(Developer).new
    @developers.each do |id|
      developers << Srcom::Api::Developers.find_by_id(id)
    end

    return developers
  end

  # Gets the full `Publisher`s that published this game.
  def full_publishers : Array(Publisher)
    publishers = Array(Publisher).new
    @publishers.each do |id|
      publishers << Srcom::Api::Publishers.find_by_id(id)
    end

    return publishers
  end

  # Gets the full `User`s that moderate this game.
  def full_moderators : Array(User)
    moderators = Array(User).new
    @moderators.each do |id, _mod_level|
      moderators << Srcom::Api::Users.find_by_id(id)
    end

    return moderators
  end

  # Gets all `Run`s completed in this `Game`.
  #
  # Defaults to getting all of them since there shouldn't be an absurd amount of `Run´s in
  # a single `Game`.
  def runs(all_pages : Bool = true, max_results_per_page : Int32 = 200) : Array(Run)
    Srcom::Api::Runs.find_by(game: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end

  # Gets all the `Level`s belonging to this game.
  def levels : Array(Level)
    Srcom::Api::Games.get_levels(@id)
  end

  # Gets all the `Category`s this game can be played in.
  def categories(miscellaneous : Bool? = nil) : Array(Category)
    Srcom::Api::Games.get_categories(@id, miscellaneous)
  end

  # Gets all the `Variable`s applicable to this game.
  def variables : Array(Variable)
    Srcom::Api::Games.get_variables(@id)
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
              all_pages : Bool = true,
              max_results_per_page : Int32 = 200) : Array(Leaderboard)
    Srcom::Api::Games.get_records(@id, top, scope, miscellaneous, skip_empty, all_pages, max_results_per_page)
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
  def derived_games(all_pages : Bool = true, max_results_per_page : Int32 = 200) : Array(Game)
    return Srcom::Api::Games.get_derived_games(@id, all_pages: all_pages, max_results_per_page: max_results_per_page)
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
