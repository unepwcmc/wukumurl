module ShortUrlsHelper
  def recently_added short_url
    return short_url.created_at > 1.minute.ago
  end

  def pretty_url ugly_url
    pretty_url = ugly_url.dup
    pretty_url.gsub!(/https{0,1}:\/\//, '')
    pretty_url.gsub!(/^www\./, '')

    return pretty_url
  end
end
