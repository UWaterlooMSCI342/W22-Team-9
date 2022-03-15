
# Acceptance Criteria: 
# 1. On student show there is a regenerate password button
# 2. When regeneration is requested new password is displayed on student show page. Ex: "Mary's password has been reset to: xd3GgTy"
# 3. Regeneration changes password and password confirmation in DB

require "application_system_test_case"

class InstructorResetPasswordTest < ApplicationSystemTestCase

    #setup taken from submit_after_wednesday.rb
    setup do
        # create prof, team, and user
        @prof = User.create(email: 'msmucker@gmail.com', name: 'Mark Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
        
        @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)

        @cici = User.create(email: 'cici@gmail.com', name: 'Cici', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
        @cici.teams << @team
        
    end



    def test_reset
        visit root_url 
        login 'msmucker@gmail.com', 'professor'

        click_on 'Manage Users'
        click_on 'Cici'
        assert_text 'Regenerate Password'
        click_on 'Regenerate Password'
        assert_current_path user_url(id:@cici.id)
        assert_text 'Password was reset to'

        #https://stackoverflow.com/questions/38665862/capybara-finding-an-element-with-id-text-or-using-multiple-properties
        element = page.all(:css, "[id='notice']").last().text

        #https://stackoverflow.com/questions/5367164/remove-substring-from-the-string
        element.slice!('Password was reset to ')
        element.slice!('. Please send this to the student')
        

        click_on 'Logout/Account'
        login 'cici@gmail.com', element
        assert_current_path root_url
    end

  end



    
