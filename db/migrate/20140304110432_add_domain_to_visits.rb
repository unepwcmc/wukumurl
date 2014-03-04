class AddDomainToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :domain, :string
  end
end
