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
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    return Srcom::Api::Runs.find_by(category: @id, page_size: page_size)
  end
end
