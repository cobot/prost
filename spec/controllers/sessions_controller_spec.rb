require 'spec_helper'

describe SessionsController, '#new' do
  it 'redirects to spaces if logged in already' do
    log_in

    get :new

    response.should redirect_to(spaces_path)
  end
end

describe SessionsController, '#create' do
  before(:each) do
    User.stub(:find_by_email)
    User.stub(:create) {stub.as_null_object}
    User.stub(:find_by_id) {stub(:user).as_null_object}
    Space.stub(:create) {stub(name: 'co-up').as_null_object}
    Space.stub(:find_by_url)
    @access_token = stub(:access_token, get: stub(:response, body: '{}')).as_null_object
    OAuth2::AccessToken.stub(:new) {@access_token}
  end

  before(:each) do
    request.env['omniauth.auth'] = {
      "credentials"=>{"token"=>"12345"},
      "extra"=>{
        "raw_info" => {
          'email' => 'joe@doe.com',
          "memberships" => [{"link" => "http://cobot.me/memberships/123",
            "space_link" => "https://www.cobot.me/api/spaces/co-up"}]
        }
      }
    }
  end

  it 'tries to find the user' do
    User.should_receive(:find_by_email).with('joe@doe.com')

    get :create, provider: 'cobot'
  end

  it 'creates a user if none found' do
    User.stub(:find_by_email) {nil}

    User.should_receive(:create).with(email: 'joe@doe.com', oauth_token: '12345')

    get :create, provider: 'cobot'
  end

  it "creates the spaces that don't exist" do
    Space.stub(:find_by_url).with('https://www.cobot.me/api/spaces/co-up') {nil}

    Space.should_receive(:create).with(url: 'https://www.cobot.me/api/spaces/co-up')

    get :create, provider: 'cobot'
  end

  it 'creates memberships' do
    User.stub(:find_by_email) {stub(:user, id: 'user-1')}
    @access_token.stub(:get).with("http://cobot.me/memberships/123") {
      stub(:response, body: {'id' => '654', 'address' => {'name' => 'joe'}}.to_json)
    }
    space = stub(:space, memberships: stub(:members, find_by_cobot_member_id: nil), name: 'co-up')
    Space.stub(:create) {space}

    space.memberships.should_receive(:create).with(name: 'joe', cobot_member_id: '654',
      user_id: 'user-1')

    get :create, provider: 'cobot'
  end

  it 'does not create members that already exist' do
    @access_token.stub(:get).with("http://cobot.me/memberships/123") {
      stub(:response, body: {'id' => '654', 'address' => {'name' => 'joe'}}.to_json)
    }
    space = stub(:space, memberships: stub(:memberships), name: 'co-up')
    space.memberships.stub(:find_by_cobot_member_id).with('654') {stub(:member)}
    Space.stub(:create) {space}

    space.memberships.should_not_receive(:create)

    get :create, provider: 'cobot'
  end

  it 'does not create spaces that already exist' do
    Space.stub(:find_by_url).with('https://www.cobot.me/api/spaces/co-up') {stub(:space).as_null_object}

    Space.should_not_receive(:create)

    get :create, provider: 'cobot'
  end

  it 'sets the user id in the session' do
    User.stub(:find_by_email) {stub(:user, id: 1).as_null_object}

    get :create, provider: 'cobot'

    session[:user_id].should == 1
  end

  it 'redirects to spaces' do
    get :create, provider: 'cobot'

    response.should redirect_to(spaces_path)
  end
end
