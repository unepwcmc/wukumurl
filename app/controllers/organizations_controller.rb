class OrganizationsController < ApplicationController
  def destroy
    organization = Organization.find(params[:id])
    organization.increment!(:disregard)
    organization.save
    redirect_to :back
  end
end
