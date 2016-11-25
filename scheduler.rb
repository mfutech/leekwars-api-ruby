#!/usr/bin/ruby
$: << File.dirname(__FILE__)
require 'rubygems'
require 'rufus-scheduler'
require 'automate'

scheduler = Rufus::Scheduler.new

scheduler.every '1d', first_at: '23:30' do 
	config = YAML.load File.open(CONFIG_FILE)
	tokens = config[:tokens]
	do_all tokens
	do_register tokens
end

scheduler.join
