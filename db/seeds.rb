file = "db/iso2_coordinates.csv"

csv_text = File.read(file)
csv = CSV.parse(csv_text, :headers => true)

csv.each do |row|
  puts row.to_hash
  CountryLocation.create!(row.to_hash)
end


['Informatics',
 'Protected Areas',
 'Species',
 'EAP',
 'Business and Biodiversity',
 'Climate Change and Biodiversity',
 'Conventions and Policy Support',
 'Development',
 'Directorate',
 'Ecosystems Assessment',
 'Marine',
 'Science'
].each do |team|
  Team.create(name: team)
end

if Rails.env == 'development'
  User.create(
    email: 'dev@unep-wcmc.org',
    password: 'password',
    password_confirmation: 'password',
    team_id: Team.where(name: 'Informatics').first.id
  )
end
