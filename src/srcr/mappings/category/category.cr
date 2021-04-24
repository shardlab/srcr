# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
# Does not cover the `Link` to get the applicable `Variable`s, since those are already embedded.
struct Srcom::Category
  include JSON::Serializable

  property id : String
  property name : String
  property weblink : String
  property type : String
  property rules : String?
  property players : Categories::Players
  property miscellaneous : Bool
  property links : Array(Link)
  @[JSON::Field(root: "data")]
  property game : SimpleGame
  @[JSON::Field(root: "data")]
  property variables : Array(Variable)

  # Gets the full `Game` resource that this `Category` belongs to.
  def full_game : Game
    return Srcom::Api::Games.find_by_id(@game.id)
  end

  # Gets all `Run`s completed in this `Category`.
  #
  # Defaults to getting all of them since there shouldn't be an absurd amount of `Run´s in
  # a single `Category`.
  def runs(all_pages : Bool = true, max_results_per_page : Int32 = 200) : Array(Run)
    return Srcom::Api::Runs.find_by(category: @id, all_pages: all_pages, max_results_per_page: max_results_per_page)
  end
end
