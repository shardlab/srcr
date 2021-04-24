struct Srcom::Run::Submission::Player
  include JSON::Serializable

  getter rel : String
  getter id : String?
  getter name : String?

  # If this `Player` is a "user" it must have an *id*; if it is a "guest" it must have a *name*.
  def initialize(@rel : String = "user", id : String? = nil, name : String? = nil)
    if @rel == "user"
      raise "Srcom::Run::Submission::Player can't be a user without an id" if id.nil?
      @id = id
    else
      raise "Srcom::Run::Submission::Player can't be a guest without a name" if name.nil?
      @name = name
    end
  end
end
