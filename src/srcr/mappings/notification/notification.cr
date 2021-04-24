# Has shorthand methods to getting the resources that the `Link`s in `#links` point to.
struct Srcom::Notification
  include JSON::Serializable

  property id : String
  property created : Time
  property status : String
  property text : String
  property item : Notification::Item
  property links : Array(Link)?

  # Returns whether this `Notification` has already been read.
  def read?
    return @status == "read"
  end

  # Returns the `Run` this `Notification` links to, if it links a `Run`.
  def run : Run?
    if (link = @links.find { |l| l.rel == "run" })
      id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
      return Srcom::Api::Runs.find_by_id(id)
    else
      # This notification doesn't have a run
      return nil
    end
  end

  # Returns the `Game` this `Notification` links to, if it links a `Game`.
  def game : Game?
    if (link = @links.find { |l| l.rel == "game" })
      id = link.uri[link.uri.rindex("/").not_nil! + 1..-1]
      return Srcom::Api::Games.find_by_id(id)
    else
      # This notification doesn't have a game
      return nil
    end
  end
end
