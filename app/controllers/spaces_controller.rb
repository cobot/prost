class SpacesController < ApplicationController
  def index
    if space = current_user.memberships.first.try(:space)
      redirect_to space_path(space)
    end
  end

  def show
    @space = Space.find_by_name!(params[:id])
  end
end
