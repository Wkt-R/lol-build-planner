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

    generate_ai_analysis(@matchup)
    redirect_to @matchup
  end

  def create_from_summoner
    summoner_name = params[:summoner_name]
    riot_client = RiotApiClient.new

    begin
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

      generate_ai_analysis(@matchup)
      redirect_to @matchup
      
    rescue => e
      Rails.logger.error("Riot API error: #{e.message}")
      redirect_to new_matchup_path, alert: "Could not fetch live game data. Please try manual input or check if the summoner is currently in a game."
    end
  end

  def generate_ai_analysis(matchup)
    begin
      prompt = PromptBuilder.new(matchup).generate
      
      ai_response = AiClient.call(prompt)
      
      parsed_response = JSON.parse(ai_response)
      
      matchup.update!(
        ai_response: ai_response,
        runes: parsed_response["runes"],
        core_items: parsed_response["core_items"],
        situational_items: parsed_response["situational_items"],
        playstyle_early: parsed_response["playstyle_early"],
        playstyle_midgame: parsed_response["playstyle_mid"] || parsed_response["playstyle_midgame"],
        playstyle_lategame: parsed_response["playstyle_late"] || parsed_response["playstyle_lategame"],
        summary: parsed_response["summary"]
      )
      
      Rails.logger.info("Successfully generated AI analysis for matchup #{matchup.id}")
      
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse AI response for matchup #{matchup.id}: #{e.message}")
      matchup.update!(
        ai_response: ai_response,
        summary: "AI analysis failed to parse properly. Please try regenerating."
      )
      
    rescue => e
      Rails.logger.error("AI analysis failed for matchup #{matchup.id}: #{e.message}")
      matchup.update!(
        summary: "AI analysis temporarily unavailable. Please try again later."
      )
    end
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