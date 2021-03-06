require "application_system_test_case"

# Acceptance Criteria: 
# 1. Given various reports in the database, when I am on the reports 
#    page, I shoul dbe able to view all those reports mentioned

class ViewRawReportSubmissionsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @team2 = Team.create(team_name: 'Test Team 2', team_code: 'TEAM02', user: @prof)
    @bob = User.create(email: 'bob@uwaterloo.ca', name: 'Bob', lastname: 'Holton', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @steve = User.create(email: 'steve@uwaterloo.ca', name: 'Steve', lastname: 'Stuart', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team2
  end
  
  # def test_view_reports 
  #   Report.create(reporter_id: @bob.id, reportee_id: @steve.id, description: 'Bob reporting Steve.')
  #   Report.create(reporter_id: @steve.id, reportee_id: @bob.id, description: 'Steve reporting Bob.')
  
  #   visit root_url 
  #   login 'msmucker@uwaterloo.ca', 'professor'
    
  #   click_on "Reports"
  #   assert_current_path reports_url
  #   assert_text 'Bob reporting Steve.'
  #   assert_text 'Steve reporting Bob.'
  # end
end
