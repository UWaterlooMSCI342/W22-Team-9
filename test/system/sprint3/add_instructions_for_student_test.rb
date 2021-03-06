require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I should be able to see help instructions regarding submission of feedbacks
# 2. As a student, I should be able to see help instructions regarding submission of reports

class AddReportsTogglesTest < ApplicationSystemTestCase
  setup do
    Option.create(reports_toggled: true)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @steve = User.create(email: 'steve@uwaterloo.ca', name: 'Steve', lastname: 'Stout', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
  end
  
  def test_feedback_instructions
    visit root_url 
    login 'steve@uwaterloo.ca', 'testpassword'    
    
    click_on "Submit for: Test Team"
    assert_text "Select the option that best represents your view of how each statement describes your team"
  end
  
  # def test_report_instructions
  #   visit root_url 
  #   login 'steve@uwaterloo.ca', 'testpassword'    
    
  #   click_on "Submit a Report"
  #   assert_text "Please select the user you wish to report and the priority of your report from the dropdowns below. Please enter a description with a maximum length of 2048 characters. These fields are mandatory."
  # end
  
end