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
- `check_token.rb` -- check validity of token in then config.yml file
- `automate.rb` -- run all possible fight from garden, register for all competitions


## note

still experimenting with this softwares, do not hesitate to make request/comments
