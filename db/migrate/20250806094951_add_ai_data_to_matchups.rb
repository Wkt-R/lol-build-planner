class AddAiDataToMatchups < ActiveRecord::Migration[7.1]
  def change
    add_column :matchups, :runes, :json
    add_column :matchups, :core_items, :json
    add_column :matchups, :situational_items, :json
    add_column :matchups, :playstyle_early, :text
    add_column :matchups, :playstyle_midgame, :text
    add_column :matchups, :playstyle_lategame, :text
    add_column :matchups, :summary, :text
  end
end
