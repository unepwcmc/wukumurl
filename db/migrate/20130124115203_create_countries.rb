class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso
      t.string :iso3
      t.string :name

      t.timestamps
    end
  end
end
