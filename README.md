[![docs](https://img.shields.io/badge/docs-master-red.svg?style=flat-square)](https://srcr.shardlab.dev/master/)

# srcr

`srcr` is a full-scale API wrapper for the [speedrun.com](https://www.speedrun.com) [API](https://github.com/speedruncomorg/api) written in [Crystal](https://crystal-lang.org/). The goal of this implementation is to provide as much data as possible / reasonable. As such, this library makes use of [embedding](https://github.com/speedruncomorg/api/blob/master/version1/embedding.md) wherever possible. Where something cannot be embedded for some reason, the library provides shorthand methods to request the data.

If you need any help with this library, feel free to reach out on the [Shard Lab Discord server](https://discord.gg/uQUrUndK6u).

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
    srcr:
        github: shardlab/srcr
```

2. Run `shards install`

## Usage

This library is an almost one to one representation of how the API itself is laid out. The different endpoints are all accessible through `Srcom::Api::<Endpoint>`, essentially mapping one class to one of the [documentation files](https://github.com/speedruncomorg/api/tree/master/version1).

### Finding Games

As an example, to find Super Mario 64 we would use the `Srcom::Api::Games` class:

```crystal
require "srcr"

games = Srcom::Api::Games.find_by(name: "Super Mario 64") # => Array(Game)

# or

games = Srcom::Api::Games.find_by(abbreviation: "sm64") # => Array(Game)

# or

game = Srcom::Api::Games.find_by_id("sm64") # => Game

# or

game = Srcom::Api::Games.find_by_id("o1y9wo6q") # => Game
```

### IDs and Abbreviations

As seen in the above example, we could use the `Srcom::Api::Games.find_by_id` method to find Super Mario 64 both by its abbreviation ("sm64") and its ID ("o1y9wo6q"). Some endpoints that ask for an ID also accept an abbreviation (the parameter will be named `id` nonetheless though!), which will then redirect to the URL with the proper ID (don't worry, srcr handles that automatically). Not all endpoints that take an ID also take an abbreviation. If they do, it will be explicitely documented.
Try to avoid actually making use of this though, as the redirect will count towards your [rate limit](#rate-limits).

### Pagination

A lot of the resources available through the API are [paginated](https://github.com/speedruncomorg/api/blob/master/version1/pagination.md) with a maximum amount of 200 elements per page (except bulk game requests, which are capped at 1000 elements per page). To minimize network usage all of these resources use a custom [`PageIterator`](https://srcr.shardlab.dev/master/Srcom/Api/PageIterator.html) which will only request the pages that you actually need. See its documentation for details on how to use it.
For all paginated endpoints srcr gives you full control over the page size but tries to set sensible defaults.
Let's try to do look for newly submitted runs as an example:

```crystal
require "srcr"

# This gets the 250 most recently submitted runs

# First, get an iterator
runs = Srcom::Api::Runs.find_by(status: "new", order_by: "verify-date", sort_direction: "desc") # => PageIterator(Run)

# Now, get the first 250 runs from that iterator
runs = runs.first(250).to_a # => Array(Run)



# If we want to get all currently unverified runs simply call `.to_a` immediately

# First, get an iterator again
runs = Srcom::Api::Runs.find_by(status: "new", page_size: 200) # => PageIterator(Run)
# Now simply call `to_a`
runs = runs.to_a # => Array(Run)
```

For another example, let's try to find the internal ID speedrun.com assigns to the PC platform:

```crystal
# Since we know for a fact speedrun.com has a platform named PC, we can use `.not_nil!`
pc_id = Srcom::Api::Platforms.get().find { |platform| platform.name == "PC" }.not_nil!.id
```

Since the `PageIterator` only requests pages when elements from them are actually asked for, it only keeps requesting pages here until the platform "PC" has been found, not all of them.

Do note that trying to get a lot of very large objects at once (namely `Run`s and especially `Game`s) can lead to the request timing out or speedrun.com throwing a 503 error. Usually `Run`s work out, but even if it goes at the expense of having to do more request try setting lower values for `page_size`.
Whenever you make a paginated request expect it to take a very long time, especially if that request wasn't made recently and speedrun.com doesn't have it cached. For reference, trying to get all unverified runs might very well take several minutes.
If a paginated request does crash for some reason, the `PageIterator` will simply use the data it has. It also sets an internal flag so you know that something during the request went wrong. For more details see [the `PageIterator`'s documentation](https://srcr.shardlab.dev/master/Srcom/Api/PageIterator.html).

### Resources that aren't embedded

This can happen for two reasons: a) the resource is impossible to embed in this scenario, or b) the resource would need a bigger recursion depth of embedding than allowed to be fully embedded.
For example, a `Category` only has a `SimpleGame` embedded. Calling `Category#full_game` will give you the full `Game` object. In fact, calling `#full_<resource>` on any object that has an un-embedded resource like that will give you that full resource.

A lot of things the API returns also come with `Link`s. For example, a `Game` has a `Link` pointing to all the `Run`s done for this game. All of these links are also available as shorthand methods. Let's get all the runs done in Super Mario 64 as an example:

```crystal
require "srcr"

game = Srcom::Api::Games.find_by_id("sm64")
runs = game.runs
```

### Rate Limits

The API is subject to [rate limits](https://github.com/speedruncomorg/api/blob/master/throttling.md). These are handled automatically by srcr. If you go over the rate limit, srcr will pause your requests until you're allowed to do them again and log a warning.

### Authentication

Most of the API is, at least for now, read-only and anonymous. For some endpoints however an API key is required, mostly when performing an action wouldn't make sense without a user context (such as using the notifications endpoint). All of the methods requiring authentication will have an `api_key` argument that takes a user's API key. If you're unsure on how to get one, read speedrun.com's documentation on [authentication](https://github.com/speedruncomorg/api/blob/master/authentication.md#aquiring-a-users-api-key).

### API Inconsistencies

The speedrun.com API has many things that are implemented in a weird, inconsistent, or undocumented way (for example, in certain contexts there can be a `Guest` with a `nil` name). Sometimes all of the three at the same time. This library tries to handle all of these as gracefully as possible. However, no guarantee can be given that every single possibly undocumented edge-case was thought of. If you encounter a `JSON::ParseError` please open an issue with the request you were trying to make, and what property couldn't be parsed.

### Full Documentation

The complete documentation for srcr is available here: https://srcr.shardlab.dev/master/

## Contributing

1. Fork it (<https://github.com/shardlab/srcr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

-   [badBlackShark](https://github.com/badBlackShark) - creator and maintainer
