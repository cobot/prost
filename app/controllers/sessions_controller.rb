class SessionsController < ApplicationController
  skip_before_filter :authenticate, only: [:new, :create, :failure]

  def new
    redirect_to spaces_path if current_user
  end

  def create
    auth = request.env['omniauth.auth']
    user = find_or_create_user(auth)
    session[:user_id] = user.id
    auth['extra']['raw_info']['memberships'].each do |hash|
      space = find_or_create_space(hash['space_link'])
      create_membership(space, hash['link'], user)
    end
    redirect_to spaces_path
  end

  def failure
    flash[:failure] = "There was a problem: #{params[:message]}"
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'You have signed out.'
    redirect_to root_path
  end

  private

  def find_or_create_space(url)
    Space.find_by_url(url) || Space.create(url: url)
  end

  def create_membership(space, url, user)
    member_hash = cobot_get url
    unless space.memberships.find_by_cobot_member_id(member_hash['id'])
      space.memberships.create name: member_hash['address']['name'],
        cobot_member_id: member_hash['id'], user_id: user.id
    end
  end

  def find_or_create_user(auth)
    User.find_by_email(auth['extra']['raw_info']['email']) || \
      User.create(email: auth['extra']['raw_info']['email'],
        oauth_token: auth['credentials']['token'])
  end

end
