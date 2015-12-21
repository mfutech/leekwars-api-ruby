require 'json'
require 'net/http'

class LeekAPI
    LeekAPI::BASE_URI = URI("http://leekwars.com")
	attr_accessor :http, :token, :cookies
	def initialize(token = nil)
		@token = token
		@garden = nil
		@leeks = nil
		start
	end
	
	def start()
		@http = Net::HTTP.start(LeekAPI::BASE_URI.host, LeekAPI::BASE_URI.port)
		@cookie = nil
	end
	
	def finish()
		@http.finish
	end

	def garden
		r = get 'garden/get'
		if r['success'] then
			return r['garden']
		else
			puts r
			raise r
		end
	end

	def leeks
		return @leeks if @leeks
		@leeks = garden['leeks'].map{|leek|leek['id']}
	end
	def get_old(rest, send_token=true, token = "")
		url = "http://leekwars.com/api/#{rest}"
		token = (token.length > 0) ? token : @token
		url = "#{url}/#{token}" if send_token
		#puts url
		res = JSON.parse RestClient.get(url)
		if res['success'] then
			return res
		else	
			raise res['error']
		end
	end
	def post_old(rest, data, send_token=true, token = "")
		url = "http://leekwars.com/api/#{rest}"
		puts url
		token = (token.length > 0) ? token : @token
		data['token'] = token if send_token
		#puts url
		puts data
		res = JSON.parse RestClient.post(url, data)
		puts res
		if res['success'] then
			return res
		else
			raise res['error']
		end
	end
	#r_init = JSON.parse RestClient.get("http://leekwars.com/api/farmer/login-token/#{login}/#{pass}")
	#token = r_init['token']
	def login(login,pass)
		res = get "farmer/login-token/#{login}/#{pass}", false
		@token = res['token']
	end
	
	def get(rest, send_token=true, token = "")
		uri = "/api/#{rest}"
		token = (token.length > 0) ? token : @token
		uri = "#{uri}/#{token}" if send_token
		headers = {}
		headers['Cookie'] = @cookies if @cookies
		#puts uri, headers
		resp = @http.get uri, headers	
		c = resp.to_hash['set-cookie']
		@cookies = @cookies.to_s + c.collect{|ea|ea[/^.*?;/]}.join if c
		res = JSON.parse resp.body
		return res
		if res['success'] then
			return res
		else
			@last_err = res
			return nil
		end
	end
	
	def post(rest, data, send_token=true, token = "")
		req = Net::HTTP::Post.new URI("#{BASE_URI}/api/#{rest}")
		token = (token.length > 0) ? token : @token
		data['token'] = token unless data.has_key? 'token'
		req['Cookie'] = @cookies if @cookies
		req.form_data = data
		#puts uri, headers
		resp = @http.request req	
		c = resp.to_hash['set-cookie']
		@cookies = @cookies.to_s + c.collect{|ea|ea[/^.*?;/]}.join if c
		res = JSON.parse resp.body
		return res
		if res['success'] then
			return res
		else
			@last_err = res
			return nil
		end
	end

	def do_solo_fight(leek_id)
		garden = get('garden/get')['garden']
		targets = garden['solo_enemies'][leek_id.to_s]
		return nil unless targets.length > 0
		target_id = targets.first['id']
		r = get "garden/start-solo-fight/#{leek_id}/#{target_id}"
		#r = api.post "garden/start-solo-fight", data
		puts r
		return true
	end
	def do_fight2()
		garden = get('garden/get')['garden']
		l = garden['leeks'][1]['id']
		puts l
		e = garden['solo_enemies'][l.to_s][0]['id']
		puts e
		data = { 'leek_id' => l, 'target_id' => e}
		puts data
		r = api.get "garden/start-solo-fight/#{l}/#{e}"
		#r = api.post "garden/start-solo-fight", data
		puts r
	end
	def do_farmer_fights
		while true do
			enemies = garden['farmer_enemies']
			break unless enemies.length > 0
			en = enemies.first
			r = get "garden/start-farmer-fight/#{en['id']}"
		#r = api.post "garden/start-solo-fight", data
			puts r
		end
	end

	def do_team_fights
		failed = 0 ## max number of failed figth submission
		garden['my_compositions'].each do |composition|
			compo_id = composition['id']
			for i in (1..20) do  ## do 20 fights at most 
				enemies = garden['enemies_compositions'][compo_id.to_s]
				break unless enemies
				enemies.each do |enemy|
					r = get "garden/start-team-fight/#{compo_id}/#{enemy['id']}"
					failed += 1 unless r['success']
					break if failed > 20
					puts r				
				end
			end
		end
	end
	
	def test(leek_id, ai_id, bots={'leek1'=>2}, type='solo')
		data = {}
		data['leek_id'] = leek_id.to_s
		data['ai_id'] = ai_id.to_s
		bots.each do |leek, bot_id|
			data["bots[#{leek}]"] = bot_id
		end
		data['type'] = 'solo'
		res = post 'ai/test', data
	end
	
	def ais
		res = get 'ai/get-farmer-ais'
		res['success'] ? res['ais'] : nil
	end
end
