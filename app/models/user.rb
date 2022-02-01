class User < ApplicationRecord
  has_secure_password
  validates_presence_of :password
    
  before_save { self.email = email.downcase }    
  validates_presence_of :email
  validates_length_of :email, maximum: 255    
  validates_uniqueness_of :email, case_sensitive: false    
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i 
    
  validates_presence_of :name
  validates_length_of :name, maximum: 40
  validates_length_of :password, minimum: 6
  validates_presence_of :password_confirmation
  validates_uniqueness_of :email
    
  has_many :teams
  has_and_belongs_to_many :teams
  has_many :feedbacks
  
  include FeedbacksHelper
    
  def role
    if self.is_admin
      return 'Professor' 
    else 
      return 'Student'
    end
  end
    
  def team_names 
    teams = Array.new
    for team in self.teams.to_ary
      teams.push(team.team_name)
    end 
    return teams
  end

  # Checks whether given user has submitted feedback for the current week
  # returns array containing all teams that do not have feedback submitted feedback for that
  # team during the week.
  def rating_reminders()
    teams = []
    d = now
    days_till_end = days_till_end(d, d.cweek, d.cwyear)
    self.teams.each do |team|
      match = false
      team.feedbacks.where(user_id: self.id).each do |feedback|
        test_time = feedback.timestamp.to_datetime
        match = match || (test_time.cweek == d.cweek && test_time.cwyear == d.cwyear)
      end
      if !match
        teams.push team
      end
    end
    # teams
    return teams
  end
    



  
  def one_submission_teams()
    teams = []
    d = now
    days_till_end = days_till_end(d, d.cweek, d.cwyear)
    self.teams.each do |team|
      match = false
      team.feedbacks.where(user_id: self.id).each do |feedback|
        test_time = feedback.timestamp.to_datetime
        match = match || (test_time.cweek == d.cweek && test_time.cwyear == d.cwyear)
      end
      if match
        teams.push team
      end
    end
    # teams
    return teams
  end
end
