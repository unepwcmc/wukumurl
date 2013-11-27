module ShortUrlsHelper
  def recently_added short_url
    return short_url.created_at > 1.minute.ago
  end
end
