require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Option.destroy_all
    Option.create(reports_toggled: true, admin_code: 'ADMIN')
    # create test user
    @user = User.new(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Charles', lastname: 'Marcos', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', name: 'Mark', lastname: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @team = Team.new(team_code: 'Code2', team_name: 'Team 1')
  end
  
  def test_create_user
    # login user
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save  
    post '/users', 
      params: {user: {email: 'scott@uwaterloo.ca', name: 'Scott', lastname: 'Marcos', password: 'banana', password_confirmation: 'banana', team_code: 'Code'}}
    assert_redirected_to root_url
  end
  
  def test_create_prof 
    assert_difference('User.count', 1) do 
      post '/users',
        params: {user: {email: 'prof@uwaterloo.ca', name: 'Professor', team_code: 'ADMIN', password: 'professor', password_confirmation: 'professor', lastname: 'Louvre'}}
      assert_redirected_to root_url 
    end 
    
    prof = User.find_by(email: 'prof@uwaterloo.ca')
    assert(prof.is_admin)
  end
  
  # 04/09/2021 for consistency with team code, admin code now case sensitive
  #def test_create_prof_insensitive_code 
  #  assert_difference('User.count', 1) do 
  #    post '/users', 
  #      params: {user: {email: 'prof@uwaterloo.ca', name: 'Professor', lastname: 'Louvre', team_code: 'admIN', password: 'professor', password_confirmation: 'professor'}}
  #    assert_redirected_to root_url 
  #  end 
  #  
  #  prof = User.find_by(email: 'prof@uwaterloo.ca')
  #  assert(prof.is_admin)
  #end
    
  def test_create_user_invalid_team
    # login user
    team = Team.new(team_code: 'Code', team_name: 'Team 1')
    team.user = @prof
    team.save  
    
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      #https://stackoverflow.com/questions/2915939/rails-testing-assert-render-action/38457649
      assert_template :new
    end
  end
  
  def test_create_user_missing_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', team_code: 'Code2'}}
      assert_template :new
    end
  end
    
  def test_create_user_invalid_name
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', lastname: 'aaa', user_id: '1010', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_student_number
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_non_unique_student_number
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_team_code
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos',}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: { password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  #also checks email converts to lowercase
  def test_create_user_non_unique_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
    
  def test_create_user_non_valid_email
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'Charles', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
  def test_create_user_missing_password_confirmation
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end

  def test_create_user_nonmatching_passwords
    assert_no_difference 'User.count' do
      post '/users', 
        params: {user: {email: 'scott@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', name: 'Scott', lastname: 'Marcos', team_code: 'Code2'}}
      assert_template :new
    end
  end
  
    
  def test_get_signup
    get '/signup'
    assert_response :success
    assert_select 'h1', 'Sign up!'
  end
  

  test "should get index" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get users_url
    assert_response :success
  end

  test "should show user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, lastname: @user.lastname, password: @user.password, password_confirmation: @user.password_confirmation } }
    assert_redirected_to user_url(@user)
  end
  

  test "should destroy user" do
    post('/login', params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

    
  def test_delete_student_as_prof
    @generated_code = Team.generate_team_code
    @team = Team.create(team_name: 'Test Team', team_code: @generated_code.to_s, user: @prof)
    @bob = User.create(email: 'bob@uwaterloo.ca', name: 'Bob', lastname: 'Laughalot', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    delete(user_path(@bob.id))
    
    User.all.each { |user| 
        assert_not_equal(@bob.name, user.name)
    }
  end
  
  def test_delete_admin_as_prof
    @ta = User.create(email: 'amir@uwaterloo.ca', name: 'Amir', lastname: 'Coughing', is_admin: true, password: 'password', password_confirmation: 'password')
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})
    delete(user_path(@ta.id))
    
    User.all.each { |user| 
        assert_not_equal(@ta.name, user.name)
    }
  end
  
  def test_delete_as_student
    @bob = User.create(email: 'bob@uwaterloo.ca', name: 'Bob', lastname: 'Laughalot', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    
    post(login_path, params: { email: 'bob@uwaterloo.ca', password: 'testpassword'})
    delete(user_path(@prof.id))
    
    assert_not_nil(User.find_by(email: 'msmucker@uwaterloo.ca'))
  end

  def test_generate_password
    @bob = User.create(email: 'bob@uwaterloo.ca', name: 'Bob', lastname: 'Laughalot', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    
    post(login_path, params: { email: 'msmucker@uwaterloo.ca', password: 'professor'})

    get(user_regenerate_password_path(@bob))
    
    assert_redirected_to user_url(@bob)
  end

end
