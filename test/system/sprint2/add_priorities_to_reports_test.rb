require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I can indicate a certain priority on my submitted report so that others can see   how urgent it is
# 2. As a user, I can view the priority of reports I am allowed to view
#    This acceptance criteria is tested in ./add_student_views_for_reports_test.rb

class AddPrioritiesToReportsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@gmail.com', name: 'Bob', lastname: 'Polsen', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @steve = User.create(email: 'steve@gmail.com', name: 'Steve', lastname: 'Tiller', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
  end
  
  def test_submit_priorities
    visit root_url 
    login 'bob@gmail.com', 'testpassword'
    
    click_on "Submit a Report"
    
    # Create report with urgent priority
    select "Steve", from: "Reportee"
    select "Urgent", from: "Priority"
    fill_in "Description", with: "URGENT"
    click_on "Submit report"
    
    click_on "Submit a Report"
    
    # Create report with medium priority
    select "Steve", from: "Reportee"
    select "Medium", from: "Priority"
    fill_in "Description", with: "MEDIUM"
    click_on "Submit report"
    
    click_on "Submit a Report"
    
    # Create report with low priority
    select "Steve", from: "Reportee"
    select "Low", from: "Priority"
    fill_in "Description", with: "LOW"
    click_on "Submit report"
    
    Report.all.each do |report|      
      assert_equal(@bob.id, report.reporter_id)
      assert_equal(@steve.id, report.reportee_id)
      
      if report.description == 'URGENT'
        assert_equal(0, report.priority)
      elsif report.description == 'MEDIUM'
        assert_equal(1, report.priority)
      else
        assert_equal(2, report.priority)
      end
    end
  end
  
  def test_view_reports_as_professor
    Report.create(reporter_id: @bob.id, reportee_id: @steve.id, description: '0', priority: 0)
    Report.create(reporter_id: @steve.id, reportee_id: @bob.id, description: '1', priority: 1)
    Report.create(reporter_id: @steve.id, reportee_id: @bob.id, description: '2', priority:2)

    visit root_url 
    login 'msmucker@gmail.com', 'professor'

    click_on "Reports"
    assert_current_path reports_url
    assert_text 'Urgent'
    assert_text 'Medium'
    assert_text 'Low'
  end
  
end