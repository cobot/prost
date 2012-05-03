class DrinksController < ApplicationController
  def create
    space = Space.find_by_name! params[:space_id]
    oauth_token.post(charges_url(space), params: {description: 'Drink', amount: 1})
    head 204
  end

  private

  def charges_url(space)
    "#{oauth_client.site[:url].sub('www', space.name)}/api/memberships/#{current_user.memberships.where(space_id: space.id).first.cobot_member_id}/charges"
  end
end
