struct Srcom::User::Region
  include JSON::Serializable

  property code : String
  property names : User::Name

  # Shorthand for `Name#international`.
  #
  # NOTE: This method is present on all things that have the `international` + `japanese` name structure.
  def name
    @names.international
  end
end
