# This keeps track of the requests being made the speedrun.com API, making sure that the rate limit
# isn't exceeded.
# To account for slight inaccuracies an additional `#backoff_time` (which defaults to 1 second) can
# be specified. This is added to the time that is needed at minimum to be allowed another request.
class Srcom::RateLimiter
  property backoff_time : Float64
  Log = Srcom::Log.for("rate_limit")

  # Makes a new `RateLimiter` with the given *backoff_time* in seconds.
  def initialize(@backoff_time : Float64 = 1)
    @entries = StaticArray(Time, 100).new { Time.unix(1) }
    @head = 0
    @mutex = Mutex.new
  end

  # Ensures the rate limit is not currently being hit.
  #
  # NOTE: *endpoint* is purely for logging purposes.
  def check_rate_limit(endpoint : String)
    @mutex.synchronize do
      if @entries[@head] < 1.minute.ago
        @entries[@head] = Time.utc
        @head = (@head + 1) % 100
        return
      else
        sleep_time = 60.seconds - (Time.utc - @entries[@head]) + @backoff_time.seconds
        Log.warn { "Hit rate limit while attempting request to #{endpoint}. Pausing requests for #{sleep_time.total_seconds} seconds." }
        sleep sleep_time.total_seconds
        @entries[@head] = Time.utc
        @head = (@head + 1) % 100
        return
      end
    end
  end

  # Waits until the oldest request occurred 60 seconds ago + twice the usual backoff time.
  #
  # NOTE: This only gets called if this `RateLimiter` fails, the rate limit gets exceeded, and
  # speedrun.com returns error code 420.
  def global_rate_limit_exceeded
    @mutex.synchronize do
      sleep_time = 60.seconds - (Time.utc - @entries[@head]) + @backoff_time.seconds * 2
      Log.warn { "Rate limit exceeded! Pausing requests for #{sleep_time.total_seconds} seconds!" }

      sleep sleep_time
    end
  end
end
