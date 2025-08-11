class RiotApiClient
  include HTTParty
  base_uri "https://euw1.api.riotgames.com"

  def initialize
    @headers = { "X-Riot-Token" => ENV["RIOT_API_KEY"] }
  end

  def summoner_by_name(name)
    self.class.get("/lol/summoner/v4/summoners/by-name/#{URI.encode_www_form_component(name)}", headers: @headers).parsed_response
  end

  def current_match(summoner_id)
    self.class.get("/lol/spectator/v4/active-games/by-summoner/#{summoner_id}", headers: @headers).parsed_response
  end
end