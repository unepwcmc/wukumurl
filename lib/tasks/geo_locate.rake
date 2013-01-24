namespace :geo_locate do
  task visits: :environment do
    Visit.un_geolocated.each do |visit|
      visit.geo_locate
      visit.save
    end
  end
end
