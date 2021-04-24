# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Variable
  include JSON::Serializable

  property id : String
  property name : String
  property category : String?
  setter scope : Variable::Scope
  property mandatory : Bool
  @[JSON::Field(key: "user-defined")]
  property user_defined : Bool
  property obsoletes : Bool
  property values : Variable::Values
  @[JSON::Field(key: "is-subcategory")]
  property is_subcategory : Bool
  property links : Array(Link)

  # Shorthand of `Scope#type`, since `Variable::Scope` wraps just this attribute anyway
  def scope
    @scope.type
  end

  # Returns the full `Category` this `Variable` belongs to, unless it belongs to all categories.
  def full_category : Category?
    id = @category
    return Srcom::Api::Categories.find_by_id(id) if id
  end

  # Returns the full `Game` this `Variable` belongs to.
  def game : Game
    link = @links.find { |l| l.rel == "game" }.not_nil!
    id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
    return Srcom::Api::Games.find_by_id(id)
  end
end
