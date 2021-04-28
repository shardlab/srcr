# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
#
# BUG: For some reason, in some contexts a `Guest` can have a `nil` name. This is a problem of the API.
struct Srcom::Guest
  include JSON::Serializable
  include JSON::Serializable::Strict

  property rel : String? # Present in certain contexts, but never relevant
  property name : String?
  property links : Array(Link)

  # This is only used in one context so we can construct a `Guest` instead of returning `nil`.
  # This also only happens if the original thing was already a `Guest` with no name, which is
  # a bug in the API.
  protected def initialize(@rel : String? = "guest", @name : String? = nil)
    @links = Array(Link).new
  end

  # Gets all `Run`s completed by this `Guest`.
  #
  # NOTE: As `Guest`s likely don't play too many runs before signing up, this request shouldn't crash.
  def runs(page_size : Int32 = 200) : Srcom::Api::PageIterator(Run)
    name = @name || ""
    return Srcom::Api::Runs.find_by(guest: name, page_size: page_size)
  end
end
