$: << File.dirname(__FILE__)
require 'leekwars'
require 'yaml'
require 'io/console'

CONFIG_FILE = File.join File.dirname(__FILE__), 'config.yml'
begin
	config = YAML.load File.open(CONFIG_FILE)
rescue
    config = {}
end

print "Login:"
login = gets.chomp
print "Password:"
IO::console.echo = false
pass = gets.chomp
IO::console.echo = true
puts 

api = LeekAPI.new
api.login login, pass

if api.token then
	puts "login successful"
	config[:tokens] = {} unless config.has_key? :tokens
	config[:tokens][login.to_sym] = api.token
	puts "config updated"
else
	puts "login failed, nothing done"
end


o = File.open CONFIG_FILE, "w"
o.write config.to_yaml
o.close

### http://pastebin.com/czf4XivU
	
