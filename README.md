# Leekwars ruby api

A simple package to handle Leekwars API from ruby

## usage

```ruby
require 'leekwars'
api = LeekAPI.new
api.login 'username', 'password'

## get the garden
api.garden

## get list of my leeks
api.garden['leeks']

```

## scripts

- `get_token.rb` -- request username password and set the config.yml accordingly, can be used multiple time, once for each account you might have
- `check_token.rb` -- check validity of token in config.yml file
- `automate.rb` -- run all possible fight from garden, register for all competitions

## How to (Docker)

To run a docker container that will run scheduler.rb once a day at 23:30, do this:

- create the docker image `docker build -t leekwars .`
- run the container `docker run -d --name lwars leekwars`
- configure the tocken `docker exec -ti lwars /usr/bin/ruby get_token.rb`
- check token are correct: `docker exec -ti lwars /usr/bin/ruby check_tocken.rb`

That's it.
*WARNING*: please change the time in scheduler.rb if you plan to let in run on a daily basis.
*WARNING*: update TZ info in the Dockerfile if you are not in CET timezone.

## note

still experimenting with this softwares, do not hesitate to make request/comments
