# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#    require 'csv'
#

  file = "db/iso2_coordinates.csv"

  csv_text = File.read(file)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    puts row.to_hash
    CountryLocation.create!(row.to_hash)
  end

