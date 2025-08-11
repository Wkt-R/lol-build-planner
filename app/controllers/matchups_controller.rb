class MatchupsController < ApplicationController
  def new
    @matchup = Matchup.new(
      ally_team: Array.new(4) { { champion: "", role: "" } },
      enemy_team: Array.new(5) { { champion: "", role: "" } }
    )
  end


  def create
    if params[:summoner_name].present?
      create_from_summoner
    else
      create_from_manual_input
    end
  end

  def show
    @matchup = Matchup.find(params[:id])
  end

  private

  def create_from_manual_input
    permitted = matchup_params

    ally_team = permitted[:ally_team].values.reject { |v| v["champion"].blank? }
    enemy_team = permitted[:enemy_team].values.reject { |v| v["champion"].blank? }

    @matchup = Matchup.create!(
      user_champion: permitted[:user_champion],
      user_role: permitted[:user_role],
      ally_team: ally_team,
      enemy_team: enemy_team
    )

    prompt = PromptBuilder.new(@matchup).generate
    fetch_and_store_ai_response(@matchup, prompt)

    redirect_to @matchup
  end

  def create_from_summoner
    summoner_name = params[:summoner_name]
    riot_client = RiotApiClient.new

    summoner = riot_client.summoner_by_name(summoner_name)
    game_data = riot_client.current_match(summoner["id"])

    player = game_data["participants"].find { |p| p["summonerName"] == summoner_name }
    user_champion = player["championName"]
    user_role = player["teamPosition"]

    allies = game_data["participants"].select { |p| p["teamId"] == player["teamId"] && p["summonerName"] != summoner_name }
    enemies = game_data["participants"].select { |p| p["teamId"] != player["teamId"] }

    ally_team = allies.map { |a| { champion: a["championName"], role: a["teamPosition"] } }
    enemy_team = enemies.map { |e| { champion: e["championName"], role: e["teamPosition"] } }

    @matchup = Matchup.create!(
      user_champion: user_champion,
      user_role: user_role,
      ally_team: ally_team,
      enemy_team: enemy_team,
      riot_match_id: game_data["gameId"].to_s
    )

    prompt = PromptBuilder.new(@matchup).generate
    fetch_and_store_ai_response(@matchup, prompt)

    redirect_to @matchup
  end
  
    def fetch_and_store_ai_response(matchup, prompt)
      content = fetch_ai_response(prompt)
    
      begin
        parsed = JSON.parse(content)
      
        matchup.update!(
          runes: parsed["runes"],
          core_items: parsed["core_items"],
          situational_items: parsed["situational_items"],
          playstyle_early: parsed["playstyle_early"],
          playstyle_midgame: parsed["playstyle_midgame"],
          playstyle_lategame: parsed["playstyle_lategame"],
          summary: parsed["summary"],
          ai_response: content # or parsed.to_json if you want a cleaner version
        )
      rescue JSON::ParserError => e
        Rails.logger.error("AI JSON parsing error: #{e.message}")
        matchup.update!(ai_response: { error: "Invalid JSON", raw: content }.to_json)
      end
    end
  
    def fetch_ai_response(matchup)
    raw_response = AiClient.call(matchup) # ← tutaj przychodzi tekst
    begin
      parsed = JSON.parse(raw_response)
    rescue JSON::ParserError => e
      Rails.logger.error("❌ AI response parsing failed: #{e.message}")
      matchup.update(ai_response: raw_response)
      return
    end
  
    matchup.update(
      ai_response: raw_response,
      runes: parsed["runes"],
      core_items: parsed["core_items"],
      situational_items: parsed["situational_items"],
      playstyle_early: parsed["playstyle_early"],
      playstyle_midgame: parsed["playstyle_mid"] || parsed["playstyle_midgame"],
      playstyle_lategame: parsed["playstyle_late"] || parsed["playstyle_lategame"],
      summary: parsed["summary"]
    )
  end
  
  def matchup_params
    params.require(:matchup).permit(
      :user_champion,
      :user_role,
      ally_team: [:champion, :role],
      enemy_team: [:champion, :role]
    )
  end
end
