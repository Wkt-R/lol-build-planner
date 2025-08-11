require "application_system_test_case"

class MatchupsTest < ApplicationSystemTestCase
  setup do
    @matchup = matchups(:one)
  end

  test "visiting the index" do
    visit matchups_url
    assert_selector "h1", text: "Matchups"
  end

  test "should create matchup" do
    visit matchups_url
    click_on "New matchup"

    fill_in "Ai response", with: @matchup.ai_response
    fill_in "Ally team", with: @matchup.ally_team
    fill_in "Enemy team", with: @matchup.enemy_team
    fill_in "Riot match", with: @matchup.riot_match_id
    fill_in "User champion", with: @matchup.user_champion
    fill_in "User role", with: @matchup.user_role
    click_on "Create Matchup"

    assert_text "Matchup was successfully created"
    click_on "Back"
  end

  test "should update Matchup" do
    visit matchup_url(@matchup)
    click_on "Edit this matchup", match: :first

    fill_in "Ai response", with: @matchup.ai_response
    fill_in "Ally team", with: @matchup.ally_team
    fill_in "Enemy team", with: @matchup.enemy_team
    fill_in "Riot match", with: @matchup.riot_match_id
    fill_in "User champion", with: @matchup.user_champion
    fill_in "User role", with: @matchup.user_role
    click_on "Update Matchup"

    assert_text "Matchup was successfully updated"
    click_on "Back"
  end

  test "should destroy Matchup" do
    visit matchup_url(@matchup)
    click_on "Destroy this matchup", match: :first

    assert_text "Matchup was successfully destroyed"
  end
end
