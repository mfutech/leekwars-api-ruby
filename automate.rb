#!/usr/bin/ruby
BASEDIR = File.dirname(__FILE__)
$: << BASEDIR

require 'leekwars'
require 'yaml'

CONFIG_FILE = File.join File.dirname(__FILE__), 'config.yml'

def do_all(tokens)
	tokens.each do |farmer, token| 
		puts "--- Farmer: #{farmer} ---------"
		api = LeekAPI.new token
		puts "--- Farmer fight"
		api.do_farmer_fights
		puts "--- Team fight"
		api.do_team_fights
		puts "--- Solo fight"
		##garden = api.get('garden/get')['garden']
		api.leeks.each do |leek|
			while api.do_solo_fight(leek) do
			end
		end
	end
	true
end

def do_register(tokens)
	tokens.each do |farmer, token| 
		puts "--- Farmer: #{farmer} ---------"
		api = LeekAPI.new token
		puts "--- register-tournament"
		api.get "farmer/register-tournament"
		api.leeks.each do |leek|
			api.get "leek/register-tournament/#{leek}"
		end
		api.garden['my_compositions'].map{|x|x['id']}.each do |compo_id|
			puts "--- register-team #{compo_id}"
			api.get "team/register-tournament/#{compo_id}"
		end
	end
end

if __FILE__ == $0 then
	$stderr.reopen File.join(BASEDIR, "err.txt"), "a"
	$stdout.reopen File.join(BASEDIR, "log.txt"), "a"
	config = YAML.load File.open(CONFIG_FILE)
	tokens = config[:tokens]
	puts "-" * 60
	puts Time.new
	do_all tokens
	do_register tokens
end

