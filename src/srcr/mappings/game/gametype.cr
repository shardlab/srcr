# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Game::Gametype
  include JSON::Serializable

  property id : String
  property name : String
  @[JSON::Field(key: "allows-base-game")]
  property allows_base_game : Bool
  property links : Array(Link)

  # Gets all `Game`s that fall under this `Gametype`.
  #
  # NOTE: Depending on the gametype this request might take quite a while. It also defaults to only 20
  # results per page as otherwise it might very well 503.
  def games(all_pages : Bool = true, max_results_per_page : Int32 = 20) : Array(Game)
    return Srcom::Api::Games.find_by(gametype: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end
end
