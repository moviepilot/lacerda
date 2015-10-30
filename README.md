# Lacerda [![Circle CI](https://circleci.com/gh/moviepilot/lacerda/tree/master.svg?style=svg)](https://circleci.com/gh/moviepilot/lacerda/tree/master) [![Coverage Status](https://coveralls.io/repos/moviepilot/lacerda/badge.svg?branch=master&service=github)](https://coveralls.io/github/moviepilot/lacerda?branch=master) [![Code Climate](https://codeclimate.com/github/moviepilot/lacerda/badges/gpa.svg)](https://codeclimate.com/github/moviepilot/lacerda) [![Dependency Status](https://gemnasium.com/moviepilot/lacerda.svg)](https://gemnasium.com/moviepilot/lacerda)

![](https://dl.dropboxusercontent.com/u/1953503/lacerda.jpg)
> «No, no -- we have to go on. We need total coverage.»<sup>[1](#references)</sup>

This gem can:

- convert MSON to JSON Schema files
- read a directory which contains one directory per service
- read a publish.mson and a consume.mson from each service
- build a model of your infrastructure knowing
  - which services publishes what to which other service
  - which service consumes what from which other service
  - if all services consume and publish conforming to their contracts.

You likely don't want to use it on its own but head on over to the [Zeta](https://github.com/moviepilot/zeta) gem which explains things in more detail. If you're just looking for ONE way to transform MSON files into JSON Schema, read on:

## Getting started
First, check out [this API Blueprint map](https://github.com/apiaryio/api-blueprint/wiki/API-Blueprint-Map) to understand how _API Blueprint_ documents are laid out:

![API Blueprint map](https://raw.githubusercontent.com/apiaryio/api-blueprint/master/assets/map.png)

You can see that their structure covers a full API use case with resource groups, single resources, actions on those resources including requests and responses. All we want, though, is the little red top level branch called `Data structures`.

We're using a ruby gem called [RedSnow](https://github.com/apiaryio/redsnow), which has bindings to [SnowCrash](https://github.com/apiaryio/snowcrash) which parses _API Blueprints_ into an AST.

Luckily, a rake task does all that for you. To convert all `*.mson` files in `contracts/` into `*.schema.json` files,

put this in your `Rakefile`:

```ruby
require "lacerda/tasks"
```

and smoke it:

```shell
/home/dev/lacerda$ DATA_DIR=contracts/ rake lacerda:mson_to_json_schema
Converting 4 files:
OK /home/dev/lacerda/contracts/consumer/consume.mson
OK /home/dev/lacerda/contracts/invalid_property/consume.mson
OK /home/dev/lacerda/contracts/missing_required/consume.mson
OK /home/dev/lacerda/contracts/publisher/publish.mson
/home/dev/lacerda$
```

## Tests and development
  - run `bundle` once
  - run `guard` in a spare terminal which will run the tests,
    install gems, and so forth
  - run `rspec spec` to run all the tests
  - check out  `open coverage/index.html` or `open coverage/rcov/index.html`
  - run `bundle console` to play around with a console

## Structure

By converting all files in a directory this gem will build up the following relationships:

- Infrastructure
  - Service
    - Contracts
      - Publish contract
        - PublishedObjects
      - Consume contract
        - ConsumedObjects

# References

[1] This quote in French quotation marks is from "Fear and Loathing in Las Vegas". Since I can't link to the book, a link to the [movie script](http://www.dailyscript.com/scripts/fearandloathing.html) shall suffice. 