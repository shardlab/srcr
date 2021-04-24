require "./iso_8601_converter.cr"

# The times without `_t` are converted from an ISO 8601 duration to a `Time::Span`. The times
# with `_t` represent the time in (possibly fractional) seconds as a `Float64`, as provided
# by the API directly
struct Srcom::Run::Times
  include JSON::Serializable

  @[JSON::Field(converter: Srcom::ISO8601Converter)]
  property primary : Time::Span?
  property primary_t : Float64
  @[JSON::Field(converter: Srcom::ISO8601Converter)]
  property realtime : Time::Span?
  property realtime_t : Float64
  @[JSON::Field(converter: Srcom::ISO8601Converter)]
  property realtime_noloads : Time::Span?
  property realtime_noloads_t : Float64
  @[JSON::Field(converter: Srcom::ISO8601Converter)]
  property ingame : Time::Span?
  property ingame_t : Float64
end
