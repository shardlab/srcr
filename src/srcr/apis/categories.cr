class Srcom::Api::Categories
  Log = Srcom::Log.for("categories")

  # Finds a `Category` by its *id*.
  def self.find_by_id(id : String) : Srcom::Category
    id = URI.encode(id)

    return Category.from_json(request_single_category(id).to_json)
  end

  # Gets all `Variable`s applicable to the `Category` specified by its *id*.
  #
  # Possible values for *order_by*: "name", "mandatory", "pos", or "user-defined", with "pos" being the default.
  #
  # Possbile values for *sort_direction*: "desc" or "asc", with "asc" being the default.
  def self.get_variables(id : String, order_by : String? = nil, sort_direction : String? = nil) : Array(Variable)
    id = URI.encode(id)

    options = Hash(String, String).new

    order = case order_by
            when Nil
              # Do nothing
            when "name", "mandatory", "pos"
              order_by
            when "user_defined", "user-defined", "userdefined"
              "user-defined"
            else
              Log.warn { %([/categories/<id>/variables] Unsupported sorting option "#{order_by}". Valid options are "name", "mandatory", "user-defined", and "pos". Defaulting to "pos".) }
              "pos"
            end

    if order
      options["orderby"] = order

      if sort_direction == "desc"
        options["direction"] = "desc"
      else
        options["direction"] = "asc"
      end
    end

    return request_category_variables(id, options).map { |variable| Variable.from_json(variable.to_json) }
  end

  # Gets the `Leaderboard` with the *top* N runs for the `Category` with the given *id*,
  # skipping over empty `Leaderboard`s if *skip_empty* is `true`.
  #
  # NOTE: This can result in more than N runs per `Leaderboard`, as ties can occur.
  # NOTE: For full game categories, this will only contain one element. For individual level
  # categories a `Leaderboard` is returned for each level for which this category is applicable.
  def self.get_records(id : String,
                       top : Int32 = 3,
                       skip_empty : Bool = false,
                       page_size : Int32 = 200) : PageIterator(Leaderboard)
    if page_size > 200
      page_size = 200
      Log.warn { "[/categories/#{id}/records] Only up to 200 results per page are supported. Request adjusted." }
    end

    options = Hash(String, String).new
    options["top"] = top.to_s
    options["skip-empty"] = skip_empty.to_s
    options["max"] = page_size.to_s

    return request_category_records(id, options)
  end

  protected def self.request_single_category(id : String)
    url = "#{BASE_URL}categories/#{id}?embed=game,variables"

    return Api.request_single_item("/categories/#{id}", url, "GET")
  end

  protected def self.request_category_variables(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)

    url = "#{BASE_URL}categories/#{id}/variables?#{params}"
    elements, _next = Api.request("/categories/#{id}/variables", url, "GET")
    return elements
  end

  protected def self.request_category_records(id : String, options : Hash(String, String))
    params = URI::Params.encode(options)
    url = "#{BASE_URL}categories/#{id}/records?embed=game,category.variables,category.game,level.categories.variables,level.categories.game,level.variables,players,regions,platforms,variables&#{params}"

    data, next_page_uri = Api.request("/categories/#{id}/records", url, "GET")
    elements = data.map { |raw| Leaderboard.from_json(raw.to_json) }
    return PageIterator(Leaderboard).new(
      endpoint: "/categories/#{id}/records",
      method: "GET",
      headers: nil,
      body: nil,
      next_page_uri: next_page_uri,
      elements: elements)
  end
end
