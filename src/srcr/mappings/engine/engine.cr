# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Engine
  include JSON::Serializable

  property id : String
  property name : String
  property links : Array(Link)

  # Gets all the `Game`s running on this `Engine`.
  #
  # NOTE: Defaults to 20 results per page as otherwise the request might very well 503.
  def games(page_size : Int32 = 20) : Srcom::Api::PageIterator(Game)
    return Srcom::Api::Games.find_by(engine: @id, page_size: page_size)
  end
end
