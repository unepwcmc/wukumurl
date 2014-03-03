require 'dasboard_client'

namespace :dasboard do
  namespace :post do
    desc "Post visit count for short urls"
    task :visit_count => :environment do  |t, args|
      urls_with_dasboard_metrics = ShortUrl.where("dasboard_metric_name IS NOT NULL")
      urls_with_dasboard_metrics.each do |url|
        puts "Posting stats for #{url.short_name} to #{url.dasboard_metric_name}..."
        DasboardClient.post_stat(url.dasboard_metric_name, url.visit_count)
      end
    end
  end
end
