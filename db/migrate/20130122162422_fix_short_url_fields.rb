class FixShortUrlFields < ActiveRecord::Migration
  def change
    change_table :short_urls do |t|
      t.rename :shortName, :short_name
    end
  end
end
