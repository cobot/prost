require 'spec_helper'

describe Space, 'callbacks' do
  it 'sets the name on create' do
    space = Space.new(url: 'https://www.cobot.me/api/spaces/co-up')
    space.run_callbacks :create

    space.name.should == 'co-up'
  end
end

describe Space, '#to_param' do
  it 'returns the name' do
    Space.new(name: 'co-up').to_param.should == 'co-up'
  end
end

