# All `Asset`s besides `#trophy_4th`, `#background`, and `#foreground` are always present.
# If the `Game`'s moderators haven't set any of them, the links will lead to speedrun.com's default
# graphics.
struct Srcom::Game::Assets
  include JSON::Serializable

  property logo : Asset
  @[JSON::Field(key: "cover-tiny")]
  property cover_tiny : Asset
  @[JSON::Field(key: "cover-small")]
  property cover_small : Asset
  @[JSON::Field(key: "cover-medium")]
  property cover_medium : Asset
  @[JSON::Field(key: "cover-large")]
  property cover_large : Asset
  property icon : Asset
  @[JSON::Field(key: "trophy-1st")]
  property trophy_1st : Asset
  @[JSON::Field(key: "trophy-2nd")]
  property trophy_2nd : Asset
  @[JSON::Field(key: "trophy-3rd")]
  property trophy_3rd : Asset
  @[JSON::Field(key: "trophy-4th")]
  property trophy_4th : Asset?
  property background : Asset?
  property foreground : Asset?
end
