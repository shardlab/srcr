# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Genre
  include JSON::Serializable

  property id : String
  property name : String
  property links : Array(Link)

  # Gets all the `Game`s belonging to this `Genre`.
  #
  # NOTE: Defaults to 20 results per page as otherwise the request might very well 503.
  def games(all_pages : Bool = true, max_results_per_page : Int32 = 20) : Array(Game)
    return Srcom::Api::Games.find_by(genre: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end
end
