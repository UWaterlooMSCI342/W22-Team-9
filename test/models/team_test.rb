require 'test_helper'
require 'date'
class TeamTest < ActiveSupport::TestCase
    include FeedbacksHelper
    
    setup do
        @prof = User.create(email: 'charles@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: true)
    end

    def test_unique_team_code_admin
      Option.destroy_all
      Option.create(reports_toggled: true, admin_code: 'admin')
      
      team2 = Team.new(team_code: 'admin', team_name: 'Team 2')
      team2.user = @prof
      assert_not team2.valid?
    end 
  
    def test_add_students
        # create test admin
        user = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
        user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
       

        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.users = [user, user2]
        assert_difference('Team.count', 1) do
            team.save
        end
    end

    def test_create_team_invalid_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with another team with same team code
        # test case insensitive
        team2 = Team.new(team_code: 'code', team_name: 'Team 2')
        team2.user = @prof
        assert_not team2.valid?
    end

    def test_create_team_blank_team_code
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with blank code
        team2 = Team.new(team_name: 'Team 2')
        team2.user = @prof
        assert_not team2.valid?
    end
    
    def test_create_team_blank_team_name
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        # try creating team with blank name
        team2 = Team.new(team_code: 'Code2')
        team2.user = @prof
        assert_not team2.valid?
    end
    
    def test_add_students_to_team
        user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
        user1.save!
        team = Team.new(team_code: 'Code', team_name: 'Team 1')
        team.user = @prof
        team.save!
        assert_difference("team.users.count", + 1) do
            team.users << user1
            team.save!
        end
    end

  def test_create_user_invalid_team_duplicate
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save!
    # try creating team with another team with same team code
    team2 = Team.new(team_code: 'Code', team_name: 'Team 2')
    team2.user = @prof
    assert_not team2.valid?
  end
  
  def test_create_user_invalid_team_code
    # too long of a code
    team2 = Team.new(team_code: 'qwertyuiopasdfghjklzxcvbnmq', team_name: 'Team 2')
    team2.user = @prof
    assert_not team2.valid?
  end

  def test_create_user_invalid_team_name
    # too long of a name
    team2 = Team.new(team_code: 'qwerty', team_name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
    team2.user = @prof
    assert_not team2.valid?
  end
    
  def test_add_students_to_team
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save!
    assert_difference("team.users.count", + 1) do
      team.users << user1
      team.save!
    end
  end

  def test_get_student_names
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.users = [user1, user2]
    team.save!

    students = team.student_names
    students.sort!
    assert_equal ['Charles1', 'Charles2'], students
  end
  
  def test_feedback_by_period_no_feedback 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save! 
    
    assert_nil(team.feedback_by_period)
  end
  
  def test_feedback_by_period_one_period
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     
    
    # rating: 9, progress_comments: "good", comments: "Test Team 1", priority: 2, goal_rating: 2, communication_rating: 2, positive_rating: 2, reach_rating:2, bounce_rating: 2, account_rating: 2, decision_rating: 2, respect_rating: 2, motivation_rating: 2
    # rating, comments, user, timestamp, team, priority, progress_comments, goal_rating, communication_rating, positive_rating, reach_rating, bounce_rating, account_rating, decision_rating, respect_rating, motivation_rating
    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_equal( 2, periods[0][1].length )
  end
  
  def test_feedback_by_period_multi_period
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     
    
    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback4 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    periods = team.feedback_by_period 
    assert_equal({year: 2021, week: 9}, periods[0][0])
    assert_equal({year: 2021, week: 7}, periods[1][0])
    assert_includes( periods[0][1], feedback )
    assert_includes( periods[0][1], feedback2 )
    assert_includes( periods[1][1], feedback3 )
    assert_includes( periods[1][1], feedback4 )
    assert_equal( 2, periods[0][1].length )
    assert_equal( 2, periods[1][1].length )
  end

  #unit test to ensure that avg function is working, modeled from above tests
  def test_avg
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     
    
    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2)
    feedback3 = save_feedback(8, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback4 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    
    avg = team.avg
    assert_equal(avg, 7)
  end
  
  #unit test to ensure that median function is working for odd number of feedbacks, modeled from above tests
  #def test_median_odd
    #user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    #user1.save!
    #user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    #user2.save!
    #user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    #user3.save!
    #team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    #team.user = @prof 
    #team.save!     
  
    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(4, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(7, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)

    
  
  #median = team.median
  #assert_equal(median, 7.0)
  #end
  
    #unit test to ensure that median function is working for even number of feedbacks, modeled from above tests
    def test_median_even
     user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    user3.save!
    user4 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles4', is_admin: false)
    user4.save!
    team = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team.user = @prof 
    team.save!     

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(2, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback4 = save_feedback(8, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
  

median = team.median
assert_equal(median, 5.0)
end


  #unit test to ensure that median function is working for even number of feedbacks, modeled from above tests
  def test_mode
   user1 = User.create(email: 'charles1@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
   user1.save!
   user2 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
   user2.save!
   user3 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
   user3.save!
   user4 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles4', is_admin: false)
   user4.save!
   team = Team.new(team_code: 'Code2', team_name: 'Team 2')
   team.user = @prof 
   team.save!     

   feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
   feedback2 = save_feedback(7, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
   feedback3 = save_feedback(7, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
   feedback4 = save_feedback(8, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)


  mode = team.mode
  assert_equal(mode, 7)
  end


  def test_find_priority_weighted_team_summary_high_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    feedback1 = save_feedback(1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 1, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(1, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "Urgent - I believe my team has serious issues and needs immediate intervention.", team_weighted_priority
  end
  
  def test_find_priority_weighted_team_summary_medium_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    feedback1 = save_feedback(1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 1, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(1, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "Medium", team_weighted_priority
  end
  
  def test_find_priority_weighted_team_summary_low_status
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    feedback1 = save_feedback(1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(1, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
    team_weighted_priority = team.find_priority_weighted(week_range[:start_date], week_range[:end_date])
    assert_equal "Low - I think my team is all good. No special attention is needed.", team_weighted_priority
  end
  
  #User Acceptance Criteria: Tests that when multiple users submit feedbacks, average is correctly calculated with denominator= # of team members.
  def test_multi_feedback_average_rating_team_summary
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!

  
    feedback1 = Feedback.new(rating: 4, progress_comments: "good", comments: "A", priority: 4, goal_rating: 4, communication_rating: 4, positive_rating: 4, reach_rating:4, bounce_rating: 4, account_rating: 4, decision_rating: 4, respect_rating: 4, motivation_rating: 4)
    feedback1.timestamp = feedback1.format_time(DateTime.now.prev_day.prev_day)
    feedback1.user = user1
    feedback1.team = team
    feedback1.save

    feedback2 = Feedback.new(rating: 2, progress_comments: "good", comments: "A", priority: 2, goal_rating: 2, communication_rating: 2, positive_rating: 2, reach_rating:2, bounce_rating: 2, account_rating: 2, decision_rating: 2, respect_rating: 2, motivation_rating: 2)
    feedback2.timestamp = feedback2.format_time(DateTime.now.prev_day.prev_day)
    feedback2.user = user2
    feedback2.team = team
    feedback2.save

    #empty feedback for user3
    feedback3 = Feedback.new(rating: 3, progress_comments: "good", comments: "A", priority: 3, goal_rating: 3, communication_rating: 3, positive_rating: 3, reach_rating:3, bounce_rating: 3, account_rating: 3, decision_rating: 3, respect_rating: 3, motivation_rating: 3)
    feedback3.timestamp = feedback3.format_time(DateTime.now.prev_day.prev_day)
    feedback3.user = user3
    feedback3.team = team
    feedback3.save
    
    feedbacks = []
    feedbacks.append(feedback1)
    feedbacks.append(feedback2)
    feedbacks.append(feedback3)

    current_week_average = Feedback::average_rating(feedbacks)
    #something wrong with this code when calculating the sum and average of feedback
    #current_week_average = Team.feedback_average_rating(team.feedback_by_period.drop(1),team.users)

    assert_equal 3.0, current_week_average
  end
  
  #rails test test/models/team_test.rb --verbose
  #User Acceptance Criteria: Tests that when 1 user does not submit feedback, average is correctly calculated with denominator= # of team members.
  def test_missed_feedback_average_rating_team_summary
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'adam2@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'adam3@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam3', is_admin: false)
    user3.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
<<<<<<< HEAD
    
<<<<<<< HEAD
    feedback1 = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
=======
    feedback1 = save_feedback(4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2)
    feedback2 = save_feedback(2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2)
    #feedback3 = save_feedback(3, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 2, 17), team, 2)
    
>>>>>>> Average works on Team's Individual
    
    current_week_average = Team.feedback_average_rating(team.feedback_by_period.first[1])
=======
  
    feedback1 = Feedback.new(rating: 4, progress_comments: "good", comments: "A", priority: 4, goal_rating: 4, communication_rating: 4, positive_rating: 4, reach_rating:4, bounce_rating: 4, account_rating: 4, decision_rating: 4, respect_rating: 4, motivation_rating: 4)
    feedback1.timestamp = feedback1.format_time(DateTime.now.prev_day.prev_day)
    feedback1.user = user1
    feedback1.team = team
    feedback1.save

    feedback2 = Feedback.new(rating: 2, progress_comments: "good", comments: "A", priority: 2, goal_rating: 2, communication_rating: 2, positive_rating: 2, reach_rating:2, bounce_rating: 2, account_rating: 2, decision_rating: 2, respect_rating: 2, motivation_rating: 2)
    feedback2.timestamp = feedback2.format_time(DateTime.now.prev_day.prev_day)
    feedback2.user = user2
    feedback2.team = team
    feedback2.save

    #empty feedback for user3
    feedback3 = Feedback.new(rating: 0, progress_comments: "empty", comments: "empty", priority: nil, goal_rating: nil, communication_rating: nil, positive_rating: nil, reach_rating:nil, bounce_rating: nil, account_rating: nil, decision_rating: nil, respect_rating: nil, motivation_rating: nil)
    feedback3.timestamp = feedback3.format_time(DateTime.now.prev_day.prev_day)
    feedback3.user = user3
    feedback3.team = team
    feedback3.save
    
    feedbacks = []
    feedbacks.append(feedback1)
    feedbacks.append(feedback2)
    feedbacks.append(feedback3)

    current_week_average = Feedback::average_rating(feedbacks)
    #something wrong with this code when calculating the sum and average of feedback
    #current_week_average = Team.feedback_average_rating(team.feedback_by_period.drop(1),team.users)
>>>>>>> unit test added
    assert_equal 2.0, current_week_average
  end

  #User Acceptance Criteria: Tests that when 1 user submit feedback, average is correctly calculated.
  def test_single_feedback_average_rating_team_summary
    week_range = week_range(2021, 7)
    
    user1 = User.create(email: 'adam1@gmail.com', password: '123456789', password_confirmation: '123456789', name: 'adam1', is_admin: false)
    user1.save!
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
  
    feedback1 = Feedback.new(rating: 4, progress_comments: "good", comments: "A", priority: 4, goal_rating: 4, communication_rating: 4, positive_rating: 4, reach_rating:4, bounce_rating: 4, account_rating: 4, decision_rating: 4, respect_rating: 4, motivation_rating: 4)
    feedback1.timestamp = feedback1.format_time(DateTime.now.prev_day.prev_day)
    feedback1.user = user1
    feedback1.team = team
    feedback1.save
    
    feedbacks = []
    feedbacks.append(feedback1)


    current_week_average = Feedback::average_rating(feedbacks)
    #something wrong with this code when calculating the sum and average of feedback
    #current_week_average = Team.feedback_average_rating(team.feedback_by_period.drop(1),team.users)
    assert_equal 4.0, current_week_average
    
  end
  
  def test_find_priority_weighted_no_feedbacks 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!
    
    team_weighted_priority = team.find_priority_weighted(DateTime.civil_from_format(:local, 2021, 2, 15), DateTime.civil_from_format(:local, 2021, 2, 21))
    assert_nil team_weighted_priority
  end
  
   def test_find_students_not_submitted_no_submissions
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save 

    # No submissions made yet 
    assert_equal([user1, user2], team.users_not_submitted([]))
  end 

  def test_find_students_not_submitted_partial_submissions
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save 

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)


    # No submissions made yet 
    assert_equal([user2], team.users_not_submitted([feedback]))

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 2, 15), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback4 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 2, 16), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
  end

  def test_find_students_not_submitted_all_submitted
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    assert_equal([], team.users_not_submitted([feedback, feedback2]))
  end

  def test_find_students_not_submitted_over_submitted 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)

    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!   
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end 

  def test_find_students_not_submitted_user_not_in_team
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!    
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.users = [user3]
    team2.user = @prof 
    team2.save

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 3, 2), team2, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    assert_equal([], team.users_not_submitted([feedback, feedback2, feedback3]))
  end

  def test_find_current_feedback 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user3, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    result = team.current_feedback(d=Date.new(2021, 3, 2))
    assert_includes( result, feedback )
    assert_includes( result, feedback2 )
    refute_includes( result, feedback3 )
    assert_equal( 2, result.length )
  end
  
  def test_generate_team_code 
    assert_equal(6, Team::generate_team_code(length = 6).size)
  end
  
  def test_status_no_users 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof 
    team.save!     

    assert_equal('green', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_status_no_feedback 
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(5, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 3), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)

    assert_equal('yellow', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_green_status
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(9, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(8, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    assert_equal('green', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_yellow_status_rating
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(6, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(7, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    assert_equal('yellow', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_yellow_status_priority
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(9, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 1, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    assert_equal('yellow', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_red_status_priority
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

    feedback = save_feedback(2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(9, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(10, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    
    assert_equal('red', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end
  
  def test_red_status_rating
    user1 = User.create(email: 'charles2@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles1', is_admin: false)
    user1.save!
    user2 = User.create(email: 'charles3@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles2', is_admin: false)
    user2.save!
    user3 = User.create(email: 'charles4@gmail.com', password: 'banana', password_confirmation: 'banana', name: 'Charles3', is_admin: false)
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.users = [user1, user2]
    team.user = @prof 
    team.save!     

<<<<<<< HEAD
    feedback = save_feedback(2, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback2 = save_feedback(2, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
    feedback3 = save_feedback(5, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2, "progress_comments", 2,2,2,2,2,2,2,2,2)
=======
    feedback = save_feedback(1, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 3, 1), team, 0)
    feedback2 = save_feedback(1, "This team is disorganized", user2, DateTime.civil_from_format(:local, 2021, 3, 27), team, 2)
    feedback3 = save_feedback(4, "This team is disorganized", user1, DateTime.civil_from_format(:local, 2021, 4, 2), team, 2)
>>>>>>> Average works on Team's Individual
    
    assert_equal('red', team.status(DateTime.civil_from_format(:local, 2021, 3, 25), DateTime.civil_from_format(:local, 2021, 4, 3)))
  end


end
