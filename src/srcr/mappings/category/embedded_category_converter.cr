# BUG: This is necessary as - when embedded - the category field is either a full Category object
# or an empty array. This should only occur in very rare cases, as this is a bug in the API, which is
# also undocumented.
class Srcom::EmbeddedCategoryConverter
  def self.from_json(pull : JSON::PullParser)
    begin
      pull.read_begin_array
      pull.read_end_array
      return nil
    rescue e : Exception
      return Category.new(pull)
    end
  end

  def self.to_json(value, builder : JSON::Builder)
    builder.string(value)
  end
end
