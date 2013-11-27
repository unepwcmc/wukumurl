file = "db/iso2_coordinates.csv"

csv_text = File.read(file)
csv = CSV.parse(csv_text, :headers => true)

csv.each do |row|
  puts row.to_hash
  CountryLocation.create!(row.to_hash)
end

if Rails.env == 'development'
  User.create(
    email: 'dev@wcmc.io',
    password: 'password',
    password_confirmation: 'password'
  )
end
