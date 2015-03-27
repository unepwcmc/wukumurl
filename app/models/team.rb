class Team < ActiveRecord::Base
  validates :name, presence: true, uniqueness:true
  has_many :users, dependent: :nullify

  def self.visits_by_team
    teams = Team.find_by_sql([
        visits_by_team_query,
        "ORDER BY visit_count DESC"
      ].join(" "))
    teams
  end

  def self.visits_by_team_query
    "SELECT teams.name, count(*) as visit_count
        FROM short_urls
        INNER JOIN users ON
        users.id= user_id
        INNER JOIN teams ON
        teams.id = team_id
        INNER JOIN visits ON
        short_urls.id = short_url_id
      GROUP BY teams.name"
  end
end
