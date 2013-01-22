class CreateShortUrls < ActiveRecord::Migration
  def change
    create_table :short_urls do |t|
      t.string :shortName
      t.text :url

      t.timestamps
    end
  end
end
