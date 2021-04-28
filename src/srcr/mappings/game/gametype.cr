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
  def games(page_size : Int32 = 20) : Srcom::Api::PageIterator(Game)
    return Srcom::Api::Games.find_by(gametype: @id, page_size: page_size)
  end
end
