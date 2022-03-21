require "application_system_test_case"

# Acceptance Criteria
# 1. As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team
# 2. As a student, I can use the generated team code to register an account associated with the team

class GenerateTeamCodesTest < ApplicationSystemTestCase
  setup do
    # SPRINT 3 UPDATE: Seed database with default option of reports_toggled = true
    Option.create(reports_toggled: true)
    
    #Create a generated team code
    @generated_code = Team.generate_team_code
  end
  
  #(1)
  def test_prof_team_creation_with_generated_code
    #(1) Passes acceptance criteria 1: As a professor, when I create a team, a generated team code is provided to allow students to add themselves to the team    
    # create professor 
    User.create(email: 'msmucker@gmail.com', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')

    # log professor in
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    # create new team
    # @team = Team.create(team_name: 'Test Team1', team_code: @generated_code.to_s, user: @prof)
    # create new team
    click_on "Manage Teams"
    find('#new-team-link').click
    
    fill_in "Team name", with: "Test Team1"
    fill_in "Team code", with: @generated_code
    click_on "Create Team"
    assert_text "Team was successfully created."

    # assert_text "Team was successfully created."
    click_on "Manage Teams"
    assert_text "Test Team1"

    
    # log professor out
    visit root_url
    click_on "Logout"
  end 
  
  #(2)
  def test_student_account_creation_with_generated_team_code
    #(2) Passes acceptance criteria 2: As a student, I can use the generated team code to register an account associated with the team
    prof = User.create(email: 'msmucker@gmail.com', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: prof)
    
    # register new student
    visit root_url
    click_on "Sign Up"
    
    fill_in "user[name]", with: "Bob"
    fill_in "user[lastname]", with: "Bold"
    fill_in "user[team_code]", with: @generated_code.to_s
    fill_in "user[email]", with: "bob@uwaterloo.ca"
    fill_in "user[password]", with: "testpassword"
    fill_in "user[password_confirmation]", with: "testpassword"
    click_on "Create account"
    
    assert_current_path root_url
    assert_text "Welcome, Bob"
    click_on "Logout"
    
    # check student enrollment (professor)
    assert_current_path login_url 
    visit root_url
    login 'msmucker@gmail.com', 'professor'
    assert_current_path root_url
    
    click_on "Manage Teams"
    assert_current_path teams_url  
    # click_on "Test Team1"
    # assert_current_path root_url 
    

    assert_text 'Bob'
    
  end
  
  
end
