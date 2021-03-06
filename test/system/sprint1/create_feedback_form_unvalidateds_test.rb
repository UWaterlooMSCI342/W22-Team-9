require "application_system_test_case"

# Acceptance Criteria: 
# 1. When I submit the feedback form, all the input data should be added to
#    the database
# 2. When I select the rating dropdown, all the appropriate ratings should
#    appear
# 3. When I submit the feedback form, the data shold be associated with my 
#    team in the database

class CreateFeedbackFormUnvalidatedsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @bob = User.create(email: 'bob@uwaterloo.ca', name: 'Bob', lastname: 'Korsen', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
  end
  
  # Test that feedback can be added using correct form (1, 2)
  def test_add_feedback 
    visit root_url 
    login 'bob@uwaterloo.ca', 'testpassword'    
    
    click_on "Submit for"
    assert_current_path new_feedback_url
    assert_text "Your Current Team: Test Team"
    
    choose('feedback[rating]', option: 4)
    select "Urgent - I believe my team has serious issues and needs immediate intervention.", :from => "feedback[priority]"
    fill_in "feedback[comments]", with: "This week has gone okay."
    click_on "Create Feedback"
    
    
    Feedback.all.each{ |feedback| 
      assert_equal(4 , feedback.overall_rating)
      assert_equal(0 , feedback.priority)
      assert_equal('This week has gone okay.', feedback.comments)
      assert_equal(@bob, feedback.user)
      assert_equal(@team, feedback.team)
    }

    
  end
  
  # Test that feedback that is added can be viewed (1, 3)
  def test_view_feedback 
    feedback = Feedback.new(rating: 4, progress_comments: "test comment", comments: "This team is disorganized", priority: 0, goal_rating: 2, communication_rating: 2, positive_rating: 2, reach_rating:2, bounce_rating: 2, account_rating: 2, decision_rating: 2, respect_rating: 2, motivation_rating: 2)
    datetime = Time.current
    feedback.timestamp = feedback.format_time(datetime)
    feedback.user = @bob
    feedback.team = @bob.teams.first
    feedback.save
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    
    click_on "Test Team", match: :first
    assert_current_path team_url(@team)
    assert_text "This team is disorganized"
    assert_text "5.5"
    assert_text "Urgent"
    assert_text "Test Team"
    assert_text datetime.strftime("%Y-%m-%d %H:%M")
  end
end
