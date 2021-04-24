# speedrun.com uses ISO 8601 formatted durations for their `Run`s. This converts them to a Time::Span.
class Srcom::ISO8601Converter
  # Regex from hell from https://github.com/moment/moment/blob/e96809208c9d1b1bbe22d605e76985770024de42/src/lib/duration/create.js#L16
  @@regex = /^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$/

  def self.from_json(pull : JSON::PullParser) : Time::Span
    string = pull.read_string
    # We're gonna assume srcom doesn't mess up giving us a valid time string and not_nil!
    # We will also disregard the sign, as speedruns of negative duration are highly unlikely
    _sign, years, months, weeks, days, hours, minutes, seconds = string.match(@@regex).not_nil!.captures
    years = years.try(&.to_f) || 0.0
    months = months.try(&.to_f) || 0.0
    weeks = weeks.try(&.to_f) || 0.0
    days = days.try(&.to_f) || 0.0
    hours = hours.try(&.to_f) || 0.0
    minutes = minutes.try(&.to_f) || 0.0
    seconds = seconds.try(&.to_f) || 0.0

    # A Time::Span can only be directly created from a float up to weeks, so we do some rounding
    days += years * 365
    days += months * 30

    # Unfortunately we can't use the initializer since it only takes ints, but we potentially have actual floats
    return weeks.weeks + days.days + hours.hours + minutes.minutes + seconds.seconds
  end

  def self.to_json(value, builder : JSON::Builder)
    builder.string(value)
  end
end
