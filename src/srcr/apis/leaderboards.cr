class Srcom::Api::Leaderboards
  Log = Srcom::Log.for("leaderboards")
  @@time_format = Time::Format.new("%F")

  # `game` and `category` can both be ids or abbreviations
  # Gets the full `Leaderboard` for the given *game* and the given *category*, where both *game*
  # and *category* can be the respective id or abbreviation, and *category* must represent
  # a per-game `Category`.
  #
  # Setting *top* will restrict each `Leaderboard` to only contain the top N runs.
  #
  # Both *platform* and *region* can be set to a `Platform` / `Region` id to restrict the `Leaderboard`
  # to only containing runs completed on that `Platform` / `Region`.
  #
  # When *emulators* is set to `true`, only runs done on an emulator will be included in the `Leaderboard`.
  # If it is set to `false`, only runs not done on an emulator will be included. If it is `nil`,
  # both runs doneon an emulated and runs done on a real system will be included.
  #
  # If *video_only* is set to `true`, only runs with video proof will be included in the `Leaderboard`.
  # If it is set to false, runs with and without video proof will be included.
  #
  # Possible values for *timing*: "realtime", "realtime_noloads", or "ingame". This ranks the runs
  # on the `Leaderboard` by that respective time.
  #
  # Setting *date* will result in only runs that were done before the given date being included
  # in the `Leaderboard`.
  #
  # The *vars* hash needs to be of the format `variable_id => value_id`, which will restrict the `Leaderboard`
  # to only include runs that have that `Variable` set to that `Variable::Values::Value`.
  #
  # NOTE: Giving a value for *timing* that the given *game* doesn't support will result in an error.
  def self.get_full_game_board(game : String,
                               category : String,
                               top : Int32? = nil,
                               platform : String? = nil,
                               region : String? = nil,
                               emulators : Bool? = nil,
                               video_only : Bool = false,
                               timing : String? = nil,
                               date : Time? = nil,
                               vars : Hash(String, String)? = nil) : Srcom::Leaderboard
    game = URI.encode(game)
    category = URI.encode(category)

    options = Hash(String, String).new
    options["top"] = top.to_s if top
    options["platform"] = platform if platform
    options["region"] = region if region
    options["emulators"] = emulators.to_s if emulators
    options["video_only"] = video_only.to_s
    options["date"] = @@time_format.format(date) if date

    case timing
    when Nil
      # Do nothing
    when "realtime", "realtime_noloads", "ingame"
      options["timing"] = timing
    else
      Log.warn { %([/leaderboards/<game>/category/<category>] Unsupported timing method #{timing} requested. Valid timing methods are "realtime", "realtime_noloads", and "ingame".) }
    end

    if vars
      vars.each do |key, value|
        options["var-#{key}"] = value
      end
    end

    return Leaderboard.from_json(request_full_game_board(game, category, options).to_json)
  end

  # `game` and `category` can both be ids or abbreviations
  # Gets the full `Leaderboard` for the given *game*, the given *category* and the given *game,
  # all of which can be their respective id or abbreviation, and where *category* needs to represent
  # a per-level `Category`.
  #
  # Setting *top* will restrict each `Leaderboard` to only contain the top N runs.
  #
  # Both *platform* and *region* can be set to a `Platform` / `Region` id to restrict the `Leaderboard`
  # to only containing runs completed on that `Platform` / `Region`.
  #
  # When *emulators* is set to `true`, only runs done on an emulator will be included in the `Leaderboard`.
  # If it is set to `false`, only runs not done on an emulator will be included. If it is `nil`,
  # both runs doneon an emulated and runs done on a real system will be included.
  #
  # If *video_only* is set to `true`, only runs with video proof will be included in the `Leaderboard`.
  # If it is set to false, runs with and without video proof will be included.
  #
  # Possible values for *timing*: "realtime", "realtime_noloads", or "ingame". This ranks the runs
  # on the `Leaderboard` by that respective time.
  #
  # Setting *date* will result in only runs that were done before the given date being included
  # in the `Leaderboard`.
  #
  # The *vars* hash needs to be of the format `variable_id => value_id`, which will restrict the `Leaderboard`
  # to only include runs that have that `Variable` set to that `Variable::Values::Value`.
  #
  # NOTE: Giving a value for *timing* that the given *game* doesn't support will result in an error.
  def self.get_level_board(game : String,
                           level : String,
                           category : String,
                           top : Int32? = nil,
                           platform : String? = nil,
                           region : String? = nil,
                           emulators : Bool? = nil,
                           video_only : Bool = false,
                           timing : String? = nil,
                           date : Time? = nil,
                           vars : Hash(String, String)? = nil) : Srcom::Leaderboard
    game = URI.encode(game)
    level = URI.encode(level)
    category = URI.encode(category)

    options = Hash(String, String).new
    options["top"] = top.to_s if top
    options["platform"] = platform if platform
    options["region"] = region if region
    options["emulators"] = emulators.to_s if emulators
    options["video_only"] = video_only.to_s
    options["date"] = @@time_format.format(date) if date

    case timing
    when Nil
      # Do nothing
    when "realtime", "realtime_noloads", "ingame"
      options["timing"] = timing
    else
      Log.warn { %([/leaderboards/<game>/level/<level>/<category>] Unsupported timing method #{timing} requested. Valid timing methods are "realtime", "realtime_noloads", and "ingame".) }
    end

    if vars
      vars.each do |key, value|
        options["var-#{key}"] = value
      end
    end

    return Leaderboard.from_json(request_level_board(game, level, category, options).to_json)
  end

  protected def self.request_full_game_board(game : String, category : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}leaderboards/#{game}/category/#{category}?embed=game,category.variables,category.game,level.categories.variables,level.categories.game,level.variables,players,regions,platforms,variables&#{params}"

    Api.request_single_item("/leaderboards/#{game}/category/#{category}", url, "GET")
  end

  protected def self.request_level_board(game : String, level : String, category : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}leaderboards/#{game}/level/#{level}/#{category}?embed=game,category.variables,category.game,level.categories.variables,level.categories.game,level.variables,players,regions,platforms,variables&#{params}"

    Api.request_single_item("/leaderboards/#{game}/level/#{level}/#{category}", url, "GET")
  end
end
