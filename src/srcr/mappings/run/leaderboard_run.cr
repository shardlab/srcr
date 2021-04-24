# A `LeaderboardRun` is equivalent to a `SimpleRun`, except that it also has a `#place`.
struct Srcom::LeaderboardRun
  include JSON::Serializable

  property place : Int32
  @run : SimpleRun

  delegate :id, :weblink, :game, :level, :category, :videos, :comment, :status, :players, :date, :submitted, :times, :system, :splits, :values, to: @run
end
