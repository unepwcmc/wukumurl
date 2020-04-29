class AddDasboardMetricId < ActiveRecord::Migration
  def change
    add_column :short_urls, :dasboard_metric_name, :string
  end
end
