struct Srcom::SimplePlayer
  include JSON::Serializable

  property rel : String
  property id : String?
  property name : String?
  property uri : String

  # Gets the full player resource as either a `User` or a `Guest`.
  def full_player : User | Guest
    if @rel == "user"
      return Srcom::Api::Users.find_by_id(@id.not_nil!)
    else
      if (name = @name)
        return Srcom::Api::Guests.find_by_name(name)
      else
        return Srcom::Guest.new
      end
    end
  end
end
