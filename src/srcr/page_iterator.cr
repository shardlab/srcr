# Iterates lazily over paginated resources, requesting new pages as the need arises.
#
# Example:
# ```
# pc = Srcom::Api::Developers.get.find { |dev| dev.name == "Bethesda" }
# ```
# Doing something like this to find that developer's id only requests the first 800 developers,
# compared to getting all >6500 of them and then filtering afterwards.
#
# It is noteworthy that Iterators, by default, only move forwards. This one's modified so that if every
# page is requested it automatically resets itself. If something like `find` is used, as in the example
# above, the Iterator needs to be reset using `#reset` for subsequent calls do work as expected though.
#
# Example:
# ```
# iterator = Srcom::Api::Developers.get
# pc = iterator.find { |dev| dev.name == "Bethesda" }
#
# # Don't use this now as this will resume counting where `find` left off:
# iterator.size
#
# # Instead, reset the Iterator first:
# iterator.reset.size
# ```
#
# If you know you only want the first n results of a paginated request, use `.first(n)` and proceed from there.
#
# NOTE: Calling methods like `to_a` or `size` will always request every page possible.
#
# ## Exceptions and incomplete data
#
# It is possible that a request fails while fetching more pages. In fact, this is unfortunately
# a fairly frequent occurrence when fetching large pages of large objects (such as `Game`s and `Run`s).
# To avoid having to wrap every use of a `PageIterator` in `begin...rescue` those exceptions are
# caught and logged. To make it possible to ensure data integrity, there's `#data_complete`. If all
# the data requested was successfully fetched it will be `true`. If a request returned with an
# error code or a `Socket::ConnectError` was thrown (usually due to the request timing out), then
# `#data_complete` will be `false`. In this case, `#status_code` will include the status code that
# was returned by speedrun.com (this will usually be 500, 502, or 503, seemingly at random).
# In case of a `Socket::ConnectError` `#status_code` will be 520 (unofficial code for an unknown error).
#
# NOTE: The fact that `#data_complete` is `true` does not mean that the complete dataset has been
# fetched, just that the data that was requested is actually complete.
class Srcom::Api::PageIterator(T)
  include Iterator(T)

  Log = Srcom::Log.for("rest")

  @endpoint : String
  @method : String
  @headers : HTTP::Headers?
  @body : String?
  @next_page_uri : String?

  @elements : Array(T)
  @head = 0
  @next_page = 2

  # Returns whether or not all requested data was successfully fetched.
  getter data_complete = true
  # Returns the status code that caused a paginated request to fail, if it did.
  getter status_code = 200

  # Creates a new `PageIterator` with the same type as the elements in the *elements* array, which
  # can be a type union.
  #
  # *endpoint* is used for logging only. Every subsequent request will also be sent with the same
  # *headers* and *body* as the original one. If there is a next page to request, it will be stored
  # in *next_page_uri*.
  def initialize(@endpoint : String,
                 @method : String,
                 @headers : HTTP::Headers?,
                 @body : String?,
                 @next_page_uri : String?,
                 @elements : Array(T))
  end

  # Returns the next element in this iterator, or `Iterator::Stop::INSTANCE` if there are no more elements.
  # Resets this iterator if all pages were successfully fetched and iterated over.
  def next
    if (element = @elements[@head]?)
      @head += 1
      element
    else
      if (uri = @next_page_uri)
        begin
          elements, next_page_uri = Api.request(@endpoint, uri, @method, @headers, page: @next_page)
          @elements += elements.map { |e| T.from_json(e.to_json) }
          @next_page_uri = next_page_uri
          element = @elements[@head]
          @head += 1
          @next_page += 1
          element
        rescue e : StatusException
          @data_complete = false
          @status_code = e.status_code
          Log.error { e.message }
          Log.error { "Paginated request to #{@endpoint} returned with #{e.status_code}. Using incomplete data." }
          @head = 0
          stop
        rescue e : Socket::ConnectError
          @data_complete = false
          @status_code = 520
          Log.error { "Paginated request to #{@endpoint} timed out. Using incomplete data." }
          @head = 0
          stop
        end
      else
        @head = 0
        stop
      end
    end
  end

  # Resets this iterator so it can be iterated over again from the start, returning `self`.
  def reset
    @head = 0
    self
  end

  # Returns the first element in the collection this iterator iterates over.
  #
  # NOTE: This is an overwrite, as by default `Iterator#first` gets the next element, not the
  # very first.
  def first
    @elements.first
  end
end
