struct Srcom::BulkGame
  include JSON::Serializable

  property id : String
  property names : BulkGame::Name
  property abbreviation : String
  property weblink : String

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end
end
