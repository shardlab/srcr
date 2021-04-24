# Adapted from github.com/shardlab/discordcr
module Srcom
  # This exception is raised in `Api#request` and `Api#request_single_item` when a request
  # fails in general, without returning a special error response.
  class StatusException < Exception
    getter response : HTTP::Client::Response

    def initialize(@response : HTTP::Client::Response)
    end

    # The status code of the response that caused this exception, for example
    # 500 or 418.
    def status_code : Int32
      @response.status_code
    end

    # The status message of the response that caused this exception, for example
    # "Internal Server Error" or "I'm A Teapot".
    def status_message : String
      @response.status_message
    end

    def message
      "#{@response.status_code} #{@response.status_message}"
    end

    def to_s(io)
      io << @response.status_code << " " << @response.status_message
    end
  end

  # An API error response.
  struct APIError
    include JSON::Serializable

    property status : Int32
    property message : String
    @links : Array(Link)
    @errors : Array(String)?

    def support_link
      @links.first.uri
    end

    def issues_link
      @links[1].uri
    end

    def errors
      @errors.try(&.join("\n"))
    end
  end

  # This exception is raised in `Api#request` and `Api#request_single_item` when a request fails with
  # an API error response that has a descriptive message and support links.
  class CodeException < StatusException
    getter error : APIError

    def initialize(@response : HTTP::Client::Response, @error : APIError)
    end

    # The API error message that was returned by Srcom, for example "Game <id> could not be found"
    # or "The submitted run does not validate against the schema. See the `errors` attached.".
    def error_message : String
      @error.message
    end

    def message
      String.build do |str|
        str << "#{@response.status_code} #{@response.status_message}: #{@error.message}\n"
        errors = @error.errors
        if errors
          str << "Errors: #{errors}\n"
        end
        str << "Get support: #{@error.support_link}\n"
        str << "Report an issue with the API: #{@error.issues_link}"
      end
    end

    def to_s(io)
      io << @response.status_code << " " << @response.status_message << ": " << @error.message
      io << "\nErrors: " << @error.errors if @error.errors
      io << "\nGet support: " << @error.support_link << "\nReport an issue with the API: " << @error.issues_link
    end
  end
end
