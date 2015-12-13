#!/usr/bin/ruby
BASEDIR = File.dirname(__FILE__)
$: << BASEDIR

require 'leekwars'
require 'yaml'

CONFIG_FILE = File.join File.dirname(__FILE__), 'config.yml'
config = YAML.load File.open(CONFIG_FILE)

tokens = config[:tokens]

tokens.each do |farmer, token|
	api = LeekAPI.new token
	res = api.get 'garden/get'
	puts "#{farmer}, success: #{res['success']}"
end


puts "Press Return"
gets