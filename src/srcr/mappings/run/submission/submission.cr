struct Srcom::Run::Submission
  include JSON::Serializable

  Log = Srcom::Log.for("run.submission")

  getter category : String
  getter level : String?
  @[JSON::Field(converter: Time::Format.new("%F"))]
  getter date : Time?
  getter region : String?
  getter platform : String?
  getter verified : Bool
  getter times : Hash(String, Float64)
  getter players : Array(Submission::Player)?
  getter emulated : Bool
  getter video : String?
  getter comment : String?
  getter splitsio : String?
  getter variables : Hash(String, Submission::Variable)?

  # Creates a run submission with the given properties (mind the notes below!).
  #
  # Valid keys for the *times* hash are: "realtime", "realtime_noloads", or "ingame"
  #
  # *date* refers to the date the run was played on. If not provided the current date will be
  # assumed to be the date the run was played on.
  #
  # *region* and *platform* must be IDs.
  #
  # Valid values for *splitsio* are a splitsio ID (such as "7h47") or a link to a link to the splits
  # on splits.io, such as "https://splits.io/7h47".
  #
  # NOTE: Unless the user submitting is a moderator of the game the run is being submitted to
  # (or a global moderator) the fields `#players` and `#verified` must not be set! If *players* is
  # not provided, the user authenticated for the run submission will be assumed to be the only
  # player of the run.
  #
  # NOTE: At least one of the timing methods specified in *times* must be one of the timing
  # methods supported by the game the run is being submit to.
  def initialize(
    @category : String,
    times : Hash(String, Float64 | Time::Span),
    @level : String? = nil,
    @date : Time? = nil,
    @region : String? = nil,
    @platform : String? = nil,
    @verified : Bool = false,
    @players : Array(Submission::Player)? = nil,
    @emulated : Bool = false,
    @video : String? = nil,
    @comment : String? = nil,
    @splitsio : String? = nil,
    @variables : Hash(String, Submission::Variable)? = nil # Variable ID => Submission::Variable
  )
    @times = Hash(String, Float64).new
    times.each do |timing, time|
      case timing
      when "realtime", "realtime_noloads", "ingame"
        if time.is_a?(Time::Span)
          @times[timing] = time.total_seconds
        else
          @times[timing] = time
        end
      else
        Log.error { "Timing #{timing} is not a valid timing method. Valid timing methods are \"realtime\", \"realtime_noloads\", or \"ingame\"." }
      end
    end
    raise "Srcom::Run::Submission needs to be initialized with at least one valid time!" if @times.empty?
  end
end
