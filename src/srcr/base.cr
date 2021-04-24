require "json"
require "http/client"

require "./mappings/game/game.cr"
require "./mappings/game/assets/assets.cr"
require "./mappings/game/assets/asset.cr"
require "./mappings/game/simple_game.cr"
require "./mappings/game/gametype.cr"
require "./mappings/game/name.cr"
require "./mappings/game/ruleset.cr"
require "./mappings/game/bulk_game.cr"
require "./mappings/game/bulk_game_name.cr"
require "./mappings/game/series.cr"
require "./mappings/category/*"
require "./mappings/developer/*"
require "./mappings/engine/*"
require "./mappings/genre/*"
require "./mappings/level/*"
require "./mappings/platform/*"
require "./mappings/publisher/*"
require "./mappings/region/*"
require "./mappings/user/user.cr"
require "./mappings/user/name.cr"
require "./mappings/user/name_style.cr"
require "./mappings/user/simple_player.cr"
require "./mappings/user/guest.cr"
require "./mappings/user/location/*"
require "./mappings/variable/variable.cr"
require "./mappings/variable/scope.cr"
require "./mappings/variable/values/values.cr"
require "./mappings/variable/values/value.cr"
require "./mappings/leaderboard/leaderboard.cr"
require "./mappings/run/run.cr"
require "./mappings/run/splits.cr"
require "./mappings/run/times.cr"
require "./mappings/run/status.cr"
require "./mappings/run/videos/videos.cr"
require "./mappings/run/videos/video_link.cr"
require "./mappings/run/system/simple_system.cr"
require "./mappings/run/pb_run.cr"
require "./mappings/run/simple_run.cr"
require "./mappings/run/leaderboard_run.cr"
require "./mappings/run/submission/submission.cr"
require "./mappings/run/submission/submission_player.cr"
require "./mappings/run/submission/submission_variable.cr"
require "./mappings/notification/notification.cr"
require "./mappings/notification/item.cr"
require "./mappings/link.cr"
require "./apis/*"

module Srcom
  # Setting the `#backoff_time` determines how much longer (in seconds) than absolutely necessary the
  # `RateLimiter` waits until it allows new requests. This defaults to 1 second.
  module Api
    extend self

    BASE_URL   = "https://www.speedrun.com/api/v1/"
    USER_AGENT = "SRCR Client (https://github.com/shardlab/srcr), version #{VERSION}"
    Log        = Srcom::Log.for("rest")

    @@rate_limiter = Srcom::RateLimiter.new

    delegate :backoff_time, to: @@rate_limiter

    # Makes a request to the given *url* using the given *method* with the given *headers* and *body*,
    # getting all pages of a paginated resource if *all_pages* is set to true.
    #
    # NOTE: *endpoint* is just used for logging purposes.
    #
    # NOTE: It is not recommended to use this method directly.
    def request(endpoint : String, url : String, method : String, headers : HTTP::Headers = HTTP::Headers.new, body : String? = nil, all_pages : Bool = true)
      headers["User-Agent"] = USER_AGENT

      @@rate_limiter.check_rate_limit(endpoint)

      Log.info { "[HTTP OUT] #{method} #{endpoint} (#{body.try &.size || 0} bytes)" }
      Log.debug { "[HTTP OUT] BODY: #{body}" }

      response = HTTP::Client.exec(method: method, url: url, headers: headers, body: body)

      Log.info { "[HTTP IN] #{response.status_code} #{response.status_message} (#{response.body.size} bytes)" }
      Log.debug { "[HTTP IN] BODY: #{response.body}" }

      if response.success?
        json = JSON.parse(response.body)
        data = json["data"].as_a

        if all_pages
          page = 2
          begin
            while json["pagination"]? && !json["pagination"]["links"].as_a.empty? && json["pagination"]["links"].as_a[-1]["rel"].as_s == "next"
              @@rate_limiter.check_rate_limit(endpoint)

              Log.info { "[HTTP OUT] #{method} #{endpoint} (#{body.try &.size || 0} bytes) (page #{page})" }
              Log.debug { "[HTTP OUT] BODY: #{body}" }

              url = json["pagination"]["links"].as_a[-1]["uri"].as_s
              response = HTTP::Client.exec(method: method, url: url, headers: headers, body: body)

              Log.info { "[HTTP IN] #{response.status_code} #{response.status_message} (#{response.body.size} bytes)" }
              Log.debug { "[HTTP IN] BODY: #{response.body}" }

              if response.success?
                json = JSON.parse(response.body)
                data += json["data"].as_a
                page += 1
                raise Socket::ConnectError.new if page == 79
              elsif response.status_code == 420
                @@rate_limiter.global_rate_limit_exceeded
              else
                raise StatusException.new(response) unless response.content_type == "application/json"

                begin
                  error = APIError.from_json(response.body)
                rescue
                  raise StatusException.new(response)
                end
                raise CodeException.new(response, error)
              end
            end
          rescue e : StatusException
            Log.error { e.message }
            Log.error { "Paginated request to #{endpoint} returned with #{e.status_code}. Returning incomplete data." }
            return data
          rescue e : Socket::ConnectError
            Log.error { "Paginated request to #{endpoint} timed out. Returning incomplete data." }
            return data
          end

          return data
        else
          return data
        end
      elsif response.status_code == 302
        request(endpoint, "https://www.speedrun.com#{response.headers["Location"]}", method, headers, body, all_pages)
      elsif response.status_code == 420
        @@rate_limiter.global_rate_limit_exceeded
        request(endpoint, url, method, headers, body, all_pages)
      else
        raise StatusException.new(response) unless response.content_type == "application/json"

        begin
          error = APIError.from_json(response.body)
        rescue
          raise StatusException.new(response)
        end
        raise CodeException.new(response, error)
      end
    end

    # Makes a request to the given *url* using the given *method* with the given *headers* and *body*,
    # with the difference to `.request` being that only a single item is returned from the API, which is
    # formatted slightly different by speedrun.com.
    #
    # NOTE: *endpoint* is just used for logging purposes.
    #
    # NOTE: It is not recommended to use this method directly.
    def request_single_item(endpoint : String, url : String, method : String, headers : HTTP::Headers = HTTP::Headers.new, body : String? = nil)
      headers["User-Agent"] = USER_AGENT

      @@rate_limiter.check_rate_limit(endpoint)
      Log.info { "[HTTP OUT] #{method} #{endpoint} (#{body.try &.size || 0} bytes)" }
      Log.debug { "[HTTP OUT] BODY: #{body}" }

      response = HTTP::Client.exec(method: method, url: url, headers: headers, body: body)

      Log.info { "[HTTP IN] #{response.status_code} #{response.status_message} (#{response.body.size} bytes)" }
      Log.debug { "[HTTP IN] BODY: #{response.body}" }

      if response.success?
        json = JSON.parse(response.body)
        return json["data"]
      elsif response.status_code == 302
        request_single_item(endpoint, "https://www.speedrun.com#{response.headers["Location"]}", method, headers, body)
      else
        raise StatusException.new(response) unless response.content_type == "application/json"

        begin
          error = APIError.from_json(response.body)
        rescue
          raise StatusException.new(response)
        end
        raise CodeException.new(response, error)
      end
    end
  end
end
