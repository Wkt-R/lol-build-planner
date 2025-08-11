class PromptBuilder
  def initialize(matchup)
    @matchup = matchup
  end

  def generate
    <<~PROMPT
      You are a League of Legends analyst. Based on the following matchup, return ONLY a valid JSON object with item build and playstyle advice.

      Matchup:
      - User Champion: #{@matchup.user_champion}
      - User Role: #{@matchup.user_role}
      - Ally Team: #{format_team(@matchup.ally_team)}
      - Enemy Team: #{format_team(@matchup.enemy_team)}

      === JSON Format ===

      {
        "runes": "Primary: Precision, Secondary: Resolve. Example: Conqueror + Triumph + Legend: Alacrity...",
        "core_items": [
          { "item": "Item name", "description": "Why it's good on this champion in this matchup" }
        ],
        "situational_items": [
          { "item": "Situational item name", "description": "When or why to take it" }
        ],
        "playstyle_early": "How to play the early game",
        "playstyle_mid": "How to play the mid game",
        "playstyle_late": "How to play the late game",
        "summary": "Concise summary of the overall strategy"
      }

      ✅ Return ONLY the JSON — do NOT include any explanation or markdown.
    PROMPT
  end

  private

  def format_team(team_data)
    team = team_data.is_a?(String) ? JSON.parse(team_data) : team_data
    team.map { |champ| "#{champ["champion"]} (#{champ["role"]})" }.join(", ")
    rescue => e
      "Invalid team data: #{e.message}"
    end
end
