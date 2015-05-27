class UsersController < ApplicationController
  def pick_team
    dont_show_map
    @teams = Team.all
  end

  def update
    if current_user.update_attributes(user_params)
      notify_slack
      redirect_to root_path
    else
      flash[:errors] ||= {}
      flash[:errors][:session] = 'Unable to update the user'

      redirect_to :back
    end
  end

  def show
    @visits_by_country = current_user.visits_by_country
    @visits_by_country_count = @visits_by_country.count
    @visits_by_organization = current_user.visits_by_organization
    @visits_by_organization_count = @visits_by_organization.count

    @total_visits = current_user.visits.length

    @short_urls = current_user.short_urls.
      with_visits.
      order('created_at DESC').
      not_deleted
  end

  private

  def user_params
    params.require(:user).permit(:team_id)
  end

  def notify_slack
    uri = URI(ENV['SLACK_WEBHOOK_URL'])
    res = Net::HTTP.post_form(uri, 'payload' => {
      username: 'wcmc-io-counter',
      icon_emoji: ':wave:',
      text: """
        A user has chosen their team, and it's #{current_user.team.name}!
        #{User.where(team_id: nil).count} more to go! :)
      """
    }.to_json)
  end
end
