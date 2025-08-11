class PromptBuilder
  def initialize(matchup)
    @matchup = matchup
  end

  def generate
    <<~PROMPT
      You are a League of Legends expert analyst. Analyze this matchup and provide a JSON response with build and strategy recommendations.

      === MATCHUP DATA ===
      User Champion: #{@matchup.user_champion}
      User Role: #{@matchup.user_role}
      Ally Team: #{format_team(@matchup.ally_team)}
      Enemy Team: #{format_team(@matchup.enemy_team)}

      === RESPONSE REQUIREMENTS ===
      Respond with ONLY a valid JSON object. No explanation, no markdown, no extra text.

      Use this EXACT structure:

      {
        "runes": "Primary and secondary rune trees with specific runes (e.g., 'Primary: Precision - Conqueror, Triumph, Legend: Alacrity, Last Stand. Secondary: Resolve - Bone Plating, Overgrowth')",
        "core_items": [
          {"item": "Item Name", "description": "Why this item is essential for this matchup"},
          {"item": "Second Item", "description": "Explanation for second core item"}
        ],
        "situational_items": [
          {"item": "Situational Item", "description": "When and why to build this item"},
          {"item": "Another Option", "description": "Alternative situational choice"}
        ],
        "playstyle_early": "Detailed early game strategy and laning approach",
        "playstyle_mid": "Mid game teamfight and objective strategy", 
        "playstyle_late": "Late game positioning and win condition strategy",
        "summary": "3-4 sentence overview of the overall game plan and key points"
      }

      === ANALYSIS GUIDELINES ===
      - Consider champion synergies and enemy threats
      - Account for current meta builds and strategies
      - Provide specific, actionable advice
      - Focus on this specific matchup context
      - Keep descriptions concise but informative

      RESPOND WITH ONLY THE JSON OBJECT:
    PROMPT
  end

  private

  def format_team(team_data)
    return "None" if team_data.blank?
    
    team = team_data.is_a?(String) ? JSON.parse(team_data) : team_data
    formatted_team = team.compact.reject { |champ| champ["champion"].blank? }
    
    if formatted_team.empty?
      "None"
    else
      formatted_team.map { |champ| "#{champ["champion"]} (#{champ["role"]})" }.join(", ")
    end
  rescue => e
    Rails.logger.error("Error formatting team data: #{e.message}")
    "Invalid team data"
  end
end