module ShortUrlsHelper
  def recently_added short_url
    return short_url.created_at > 1.minute.ago
  end

  def pretty_url url
    url.gsub!(/https{0,1}:\/\//, '')
    url.gsub!(/^www\./, '')
    return url
  end
end
