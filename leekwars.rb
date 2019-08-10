require 'json'
require 'net/http'
require 'openssl'
require 'http-cookie'

class LeekAPI
  LeekAPI::BASE_URI = URI("https://leekwars.com")
  attr_accessor :http, :token, :jar

  def initialize(token = nil)
    @token = token
    @leeks = nil
    @farmer = nil
    @jar = HTTP::CookieJar.new
    start
  end
  
  def start()
    @http = Net::HTTP.start(LeekAPI::BASE_URI.host,
                            LeekAPI::BASE_URI.port,
                            :use_ssl => LeekAPI::BASE_URI.scheme == 'https',
                            :verify_mode => OpenSSL::SSL::VERIFY_NONE)
    @cookie = nil
  end
  
  def finish()
    @http.finish
  end
  
  def get_garden
    r = get 'garden/get'
    return r['garden'] if r 
    raise r
  end

  def dis_garden
    @garden = get_garden unless @garden
    return @garden
  end
  
  def leeks
    return @leeks if @leeks
    @leeks = farmer['leeks'].map{|leek_id,leek| leek_id}
  end

  def farmer
    return @farmer if @farmer
	  @farmer = (get 'farmer/get-from-token')['farmer']
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
    return @token != nil
  end
  
  def get(rest, send_token=true, token = "")
    url = "https://leekwars.com/api/#{rest}"

    token = (token.length > 0) ? token : @token

    headers = {}
    headers['Cookie'] = HTTP::Cookie.cookie_value(@jar.cookies(url))
    headers['Authorization'] = "Bearer #{token}"

    resp = @http.get url, headers	

    cookies_set = resp.to_hash['set-cookie']
    if cookies_set then
      cookies_set.each { |value| @jar.parse(value, url) }
    end

    res = JSON.parse resp.body
    
    raise RuntimeError, resp.body if res.class != Hash
    raise RuntimeError, res['error'] if res.has_key? 'error'
    return res

  end

  def post(rest, data, send_token=true, token = "")
    url = "https://leekwars.com/api/#{rest}"

    token = (token.length > 0) ? token : @token

    headers = {}
    headers['Cookie'] = HTTP::Cookie.cookie_value(@jar.cookies(url))
    headers['Authorization'] = "Bearer #{token}"

    resp = @http.post url, data.to_json, headers	
    
    cookies_set = resp.to_hash['set-cookie']
    if cookies_set then
      cookies_set.each { |value| @jar.parse(value, url) }
    end

    res = JSON.parse resp.body
    raise RuntimeError, res['error'] if res.has_key? 'error'
    return res
  end

  def do_solo_fight(leek_id)
    #garden = get('garden/get')['garden']
    #targets = garden['solo_enemies'][leek_id.to_s]
	  opponents = get( "garden/get-leek-opponents/#{leek_id}" )['opponents']
    return nil unless opponents.length > 0
    target_id = opponents.first['id']
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
      #enemies = garden['farmer_enemies']
	    opponents = get( "garden/get-farmer-opponents" )['opponents']
      break unless opponents && opponents.length > 0
      farmer_id = opponents.first['id']
      r = get "garden/start-farmer-fight/#{farmer_id}"
      #r = api.post "garden/start-solo-fight", data
      puts r
    end
  end

  def do_team_fights
    failed = 0 ## max number of failed figth submission
    garden = get_garden()
    garden['my_compositions'].each do |composition|
      compo_id = composition['id']
      for i in (1..20) do  ## do 20 fights at most 
        #enemies = garden['enemies_compositions'][compo_id.to_s]
        opponents = get( "garden/get-composition-opponents/#{compo_id}" )['opponents']
        break unless opponents
        opponents.each do |opponent|
          begin
            r = get "garden/start-team-fight/#{compo_id}/#{opponent['id']}"
            failed += 1 unless r['success']
            break if failed > 20
            puts r				
          rescue RuntimeError => e
            puts e  
          end
        end
      end
    end
  end
end
