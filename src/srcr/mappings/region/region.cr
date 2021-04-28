# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Region
  include JSON::Serializable

  property id : String
  property name : String
  property links : Array(Link)

  # Gets all the `Game`s playable in this `Region`.
  #
  # NOTE: Defaults to 20 results per page as otherwise the request might very well 503.
  def games(page_size : Int32 = 20) : Srcom::Api::PageIterator(Game)
    return Srcom::Api::Games.find_by(region: @id, page_size: page_size)
  end

  # Gets all `Run`s completed while playing on this `Platform`.
  #
  # NOTE: Depending on the `Region` trying to get all `Run`s almost definitely crashes at some point.
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    return Srcom::Api::Runs.find_by(region: @id, page_size: page_size)
  end
end
