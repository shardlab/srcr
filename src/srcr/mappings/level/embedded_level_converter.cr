# This is necessary as - when embedded - the level field is either a full Level object
# or an empty array. For some reason srcom chose to not just make the value null if not present.
class Srcom::EmbeddedLevelConverter
  def self.from_json(pull : JSON::PullParser)
    begin
      pull.read_begin_array
      pull.read_end_array
      return nil
    rescue e : Exception
      return Level.new(pull)
    end
  end

  def self.to_json(value, builder : JSON::Builder)
    builder.string(value)
  end
end
