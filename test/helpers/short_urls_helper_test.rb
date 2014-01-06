require 'test_helper'

class ShortUrlsHelperTest < ActionView::TestCase
  test '#pretty_url strips http:// from the given url' do
    url = 'http://google.com'
    expected_url = 'google.com'

    assert_equal expected_url, pretty_url(url)
  end

  test '#pretty_url strips https:// from the given url' do
    url = 'https://google.com'
    expected_url = 'google.com'

    assert_equal expected_url, pretty_url(url)
  end

  test '#pretty_url strips www. from the given url' do
    url = 'www.google.com'
    expected_url = 'google.com'

    assert_equal expected_url, pretty_url(url)
  end

  test '#pretty_url only strips www. from the start of the given url' do
    url = 'www.www.com'
    expected_url = 'www.com'

    assert_equal expected_url, pretty_url(url)
  end
end
