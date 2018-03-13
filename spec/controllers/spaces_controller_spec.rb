require 'spec_helper'

describe SpacesController, 'index', type: :controller do
  it 'redirects to the first space' do
    log_in double(:user, memberships: [double(:membership, space: 'co-up')])

    get :index

    response.should redirect_to(space_path('co-up'))
  end

  it 'renders index if user has no spaces' do
    log_in double(:user, memberships: [])

    get :index

    response.should render_template('index')
  end
end

describe SpacesController, 'show', type: :controller do
  let(:user) { double(:user) }

  before(:each) do
    log_in user
  end

  it 'loads the space' do
    Space.should_receive(:find_by_name!).with('co-up') { double(:space).as_null_object }

    get :show, id: 'co-up'
  end

  it 'assigns the space' do
    space = double(:space).as_null_object
    Space.stub(:find_by_name!) {space}

    get :show, id: 'co-up'

    assigns(:space).should == space
  end
end
