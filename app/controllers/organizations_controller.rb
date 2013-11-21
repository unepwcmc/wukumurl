class OrganizationsController < ApplicationController
  def destroy
    organization = Organization.find(params[:id])

    DisregardVote.create(
      organization: organization,
      short_url_id: params[:short_url_id]
    )

    redirect_to :back
  end
end
