# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
# Does not cover the `Link`s to `Category`s and `Variable`s, since those are already embedded.
struct Srcom::Level
  include JSON::Serializable

  property id : String
  property name : String
  property weblink : String
  property rules : String?
  property links : Array(Link)
  @[JSON::Field(root: "data")]
  property categories : Array(Category)
  @[JSON::Field(root: "data")]
  property variables : Array(Variable)

  # Gets the `Game` that this `Level` belongs to.
  def game : Game
    link = @links.find { |l| l.rel == "game" }.not_nil!
    id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
    return Srcom::Api::Games.find_by_id(id)
  end

  # Gets all `Run`s completed for this `Level`.
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    return Srcom::Api::Runs.find_by(level: @id, page_size: page_size)
  end
end
