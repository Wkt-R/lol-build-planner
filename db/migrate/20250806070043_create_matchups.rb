class CreateMatchups < ActiveRecord::Migration[7.1]
  def change
    create_table :matchups do |t|
      t.string :user_champion
      t.string :user_role
      t.json :ally_team
      t.json :enemy_team
      t.text :ai_response
      t.string :riot_match_id

      t.timestamps
    end
  end
end
