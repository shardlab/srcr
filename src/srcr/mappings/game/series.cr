# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Series
  include JSON::Serializable

  property id : String
  property names : Game::Name
  property abbreviation : String
  property weblink : String
  @[JSON::Field(root: "data")]
  property moderators : Array(User)
  property created : Time?
  property assets : Game::Assets
  property links : Array(Link)

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end

  # Gets all `Game`s that belong to this `Series`.
  #
  # NOTE: Depending on the series this request might take quite a while. It also defaults to only 20
  # results per page as otherwise it might very well 503.
  def games(all_pages : Bool = true, max_results_per_page : Int32 = 20) : Array(Game)
    return Srcom::Api::Series.get_games(@id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end
end
