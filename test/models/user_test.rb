require 'test_helper'
require 'minitest/autorun'

class UserTest < ActiveSupport::TestCase

   def setup 
    @user = User.create(email: 'scott@uwaterloo.ca', password: 'password', password_confirmation: 'password', name: 'Scott', lastname: 'A', is_admin: false)
    @prof = User.create(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Charles', lastname: 'Brown', is_admin: true)
   end
    
  def test_role_function_professor
    professor = User.new(email: 'azina@uwaterloo.ca', password: 'password', password_confirmation: 'password', name: 'Azin', lastname: 'Lazy', is_admin: true) 
    assert_equal('Professor', professor.role)
  end 
  
  def test_role_function_student 
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false)
    assert_equal('Student', user1.role)
  end 
  
  def test_team_names 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save
    team2 = Team.new(team_code: 'Code2', team_name: 'Team 2')
    team2.user = @prof 
    team2.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false, teams: [team, team2])
    assert_equal(['Team 1', 'Team 2'], user1.team_names)
  end
  
  def test_one_submission_no_submissions
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false, teams: [team])
    assert_equal([], user1.one_submission_teams)
  end
  
  def test_one_submission_existing_submissions 
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false, teams: [team])
    save_feedback(5, 'Test', user1, Time.zone.now, team, 1, "progress_comments", 2,2,2,2,2,2,2,2,2)
    assert_equal([team], user1.one_submission_teams)
  end
  
  # 1) As a user, I cannot create an account with a duplicate email
  test 'valid signup' do
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save
    user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false, teams: [team])
    assert user1.valid?

  end
    
  #test that two professors can signup
  test 'valid prof signup' do
     professor = User.new(email: 'azina@uwaterloo.ca', password: 'password', password_confirmation: 'password', name: 'Azin', lastname: 'Lazy', is_admin: true) 
     assert professor.valid?
  end
  
  test 'invalid signup without unique email' do
      user1 = User.new(email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'F', is_admin: false)
      refute user1.valid?, 'user must have unique email'
      assert_not_nil user1.errors[:email]
  end
    
  # 4) As a user, I cannot create an account with a password less than 6 characters
  test 'invalid signup password' do
      user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'apple', password_confirmation: 'apple', name: 'Scott', lastname: 'F', is_admin: false)
      refute user1.valid?, 'user password must have at least 6 characters'
      assert_not_nil user1.errors[:password]
  end
  #name is too long
  test 'invalid signup name' do
      user1 = User.new(email: 'scottf@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', lastname: 'aaa', is_admin: false)
      refute user1.valid?, 'user name must have less than 40 characters'
      assert_not_nil user1.errors[:name]
  end

  # As a student, I should be able to see the number of days until a weekly rating is due,
  # and I should only see that if there are ratings due.
  def test_rating_reminders
    user = User.new(email: 'charles42@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Charles', lastname: 'Brown', is_admin: false)
    user.save!

    team = Team.new(team_name: 'Hello World', team_code: 'Code', user: user)
    team.save!
    team2 = Team.new(team_name: 'Team Name', team_code: 'Code2', user: user)
    team2.save!
    user.teams << [team, team2]
    user.save!
    reminders = user.rating_reminders
    assert_equal reminders.size, 2

    # create feeedback for team
    datetime = Time.zone.now
    feedback = Feedback.new(rating: 4, comments: "This team is disorganized",  goal_rating: 4, communication_rating: 4, positive_rating: 4, reach_rating: 4, bounce_rating: 4, account_rating: 4, decision_rating: 4, respect_rating: 4, progress_comments: "Test progress", motivation_rating: 4 )
    feedback.timestamp = feedback.format_time(datetime)
    feedback.user = user
    feedback.team = team
    feedback.save! 

    # ensure that feedback created in previous week does not stop warning from displaying 
    datetime2 = DateTime.new(1990,2,3)
    feedback2 = Feedback.new(rating: 4, comments: "This team is disorganized",  goal_rating: 4, communication_rating: 4, positive_rating: 4, reach_rating: 4, bounce_rating: 4, account_rating: 4, decision_rating: 4, respect_rating: 4, progress_comments: "Test progress", motivation_rating: 4 )
    feedback2.timestamp = feedback2.format_time(datetime2)
    feedback2.user = user
    feedback2.team = team2
    feedback2.save!
    array = user.rating_reminders
    array = array.map { |team| team.team_name }
    assert_equal true, array.include?("Team Name")
    assert_equal 1, array.size
  end

  #testing random password generation
  def test_gen_new_pass
    new_pass = @user.gen_new_pass
    new_pass_with_len = @user.gen_new_pass 4
    assert_equal(8, new_pass.length)
    assert_equal(4, new_pass_with_len.length)
  end

  #testing password reset
  #Note for all password reset tests @user.save is not called as passwords can then not be done
  #This is tested instead in integration tests
  def test_reset_pass_with_generated
    @user.reset_pass_with_generated 'acccd1234'
    assert_equal('acccd1234',@user.password)
    assert_equal('acccd1234',@user.password_confirmation)
  end

  #testing value of password reset method
  def test_reset_pass_with_generated_value
    value = @user.reset_pass_with_generated 'acccd1234'
    assert_equal(true,value)
  end

  #testing password that is empty string
  def test_reset_pass_with_failure
    @user.reset_pass_with_generated ''
    assert_equal('password', @user.password)
  end

  #testing password that is too short
  def test_reset_pass_with_failure_value
    value = @user.reset_pass_with_generated ''
    @user.save
    assert_equal(false, value)
  end

end
