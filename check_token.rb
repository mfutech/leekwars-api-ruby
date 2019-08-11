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
	begin
		res = api.get 'garden/get'
		puts "#{farmer}, success: #{res['success']}"
	rescue RuntimeError => e
		puts "Cannot Connect: #{e}"
	end
end


puts "Press Return"
gets