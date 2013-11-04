class OrganizationsController < ApplicationController
  def destroy
    organization = Organization.find(params[:id])
    organization.disregard = true
    organization.save
    redirect_to :back
  end
end
