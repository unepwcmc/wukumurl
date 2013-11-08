DELETE FROM cities;
DELETE FROM locations;
DELETE FROM organizations;
UPDATE visits SET city_id = NULL, orGanization_id = NULL, location_id = NULL, country_id = NULL