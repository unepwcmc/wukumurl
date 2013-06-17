require 'csv'


desc "Import teams from csv file"
task :import => [:environment] do

  file = "db/iso2_coordinates.csv"

  csv_text = File.read(file)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    CountryLocation.create!(row.to_hash)
  end

end
