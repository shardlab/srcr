# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Region
  include JSON::Serializable

  property id : String
  property name : String
  property links : Array(Link)

  # Gets all the `Game`s playable in this `Region`.
  #
  # NOTE: Defaults to 20 results per page as otherwise the request might very well 503.
  def games(all_pages : Bool = true, max_results_per_page : Int32 = 20) : Array(Game)
    return Srcom::Api::Games.find_by(region: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end

  # Gets all `Run`s completed while playing on this `Platform`.
  #
  # NOTE: Depending on the `Region` this request almost definitely crashes at some point.
  def runs(all_pages : Bool = true, max_results_per_page : Int32 = 200) : Array(Run)
    return Srcom::Api::Runs.find_by(region: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end
end
