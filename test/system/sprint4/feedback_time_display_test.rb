require "application_system_test_case"

# Acceptance Criteria:
# 1. As student, I should be able to see the time I have started a feedback
# 2. As a student, I should be able to see the time that I have submitted a feedback

class FeebackTimeDisplayTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@gmail.com', password: 'asdasd', password_confirmation: 'asdasd', name: 'Zac', is_admin: false)
    @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
    @user.teams << @team
    @user.save
      
    # Time.zone = 'Pacific Time (US & Canada)'

    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
  end 
    
  def test_time_displays
      


    visit root_url
    login 'test@gmail.com', 'asdasd'
    assert_current_path root_url
    
    click_on "Submit for"
    assert_text "Current System Time: 2021/03/21 23:30" #Acceptance criteria #1
    choose('feedback[rating]', option: 4)
    select "Urgent - I believe my team has serious issues and needs immediate intervention.", :from => "feedback[priority]"
    click_on "Create Feedback"
    assert_current_path root_url
    assert_text "Feedback was successfully created. Time created: 2021-03-21 23:30:00" #Acceptance criteria #2
  end 
  
end