#!/usr/bin/ruby
$: << File.dirname(__FILE__)
require 'rubygems'
require 'rufus-scheduler'
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
		api.garden['leeks'].each do |leek|
			leek_id = leek['id']
			while api.do_solo_fight(leek_id) do
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



scheduler = Rufus::Scheduler.new

scheduler.every '1d', first_at: '23:30' do 
	config = YAML.load File.open(CONFIG_FILE)
	tokens = config[:tokens]
	do_all tokens
	do_register tokens
end

scheduler.join
