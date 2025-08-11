json.extract! matchup, :id, :user_champion, :user_role, :ally_team, :enemy_team, :ai_response, :riot_match_id, :created_at, :updated_at
json.url matchup_url(matchup, format: :json)
