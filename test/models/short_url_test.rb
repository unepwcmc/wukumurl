require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  def setup
    @short_url = FactoryGirl.create(:short_url)

    @visit_today = FactoryGirl.create(:visit, short_url: @short_url)
    @visit_yesterday = FactoryGirl.create(:visit,
      short_url: @short_url,
      created_at: 2.days.ago.to_s(:db)
    )
    @visit_last_week = FactoryGirl.create(:visit,
      short_url: @short_url,
      created_at: 1.week.ago.to_s(:db)
    )
    @visit_last_month = FactoryGirl.create(:visit,
      short_url: @short_url,
      created_at: 2.month.ago.to_s(:db)
    )

    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: FactoryGirl.create(:organization, name: 'Apple')
    )

    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: FactoryGirl.create(:organization, name: 'WCMC')
    )

    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: FactoryGirl.create(:organization, name: 'BT', disregard: 1)
    )

    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: FactoryGirl.create(:organization, name: 'Virgin Media', disregard: 5)
    )
  end

  test "visits_today should return only visits from today" do
    assert @short_url.visits_today.to_a.include?(@visit_today)
    assert !@short_url.visits_today.to_a.include?(@visit_yesterday)
  end

  test "visits_this_week should return only visits from this week" do
    visits_this_week = @short_url.visits_this_week
    assert visits_this_week.to_a.include?(@visit_today)
    assert visits_this_week.to_a.include?(@visit_yesterday)
    assert !visits_this_week.to_a.include?(@visit_last_week)
  end

  test "visits_this_month should return only visits from this month" do
    visits_this_month = @short_url.visits_this_month
    assert visits_this_month.to_a.include?(@visit_today)
    assert visits_this_month.to_a.include?(@visit_yesterday)
    assert visits_this_month.to_a.include?(@visit_last_week)
    assert !visits_this_month.to_a.include?(@visit_last_month)
  end

  test "visits_by_country should return stats correctly" do
    FactoryGirl.create(:visit, short_url: @short_url, city: FactoryGirl.create(:city))

    country_stats = @short_url.visits_by_country
    counts = {}
    country_stats.each do |city|
      counts[city.country] = city.visit_count.to_i
    end

    assert_equal 1, counts["Canada"]
  end

  test "visits_by_organization should return stats correctly with grouping disabled" do
    organization_stats = @short_url.visits_by_organization group_by_disregarded: false

    counts = {}
    organization_stats.each do |organization|
      counts[organization.name] = organization.visit_count.to_i
    end

    assert_equal 1, counts["Apple"]
    assert_equal 1, counts["WCMC"]
  end

  test "visits_by_organization with group_by_diregarded = true
    separates the visits in to pertinent and non-pertinent depending on
    the Organization's disregard count" do
    organization_stats = @short_url.visits_by_organization(group_by_disregarded: true)

    counts = {}
    organization_stats.each do |pertinence, organizations|
      organizations.each do |organization|
        counts[pertinence] ||= {}
        counts[pertinence][organization.name] = organization.visit_count.to_i
      end
    end

    assert_equal 1, counts[:pertinent]["Apple"]
    assert_equal 1, counts[:pertinent]["WCMC"]
    assert_equal 1, counts[:pertinent]["BT"]
    assert_equal 1, counts[:non_pertinent]["Virgin Media"]
  end

  test "saving a link with no http:// in front should have it inserted" do
    no_http = FactoryGirl.create(:short_url, url: "bbc.co.uk")
    assert_equal "http://bbc.co.uk", no_http.url
  end

  test "saving a link with http:// in front should not modify the url" do
    http = FactoryGirl.create(:short_url, url: "http://bbc.co.uk")
    assert_equal "http://bbc.co.uk", http.url
  end

  test "saving a link with https:// in front should not modify the url" do
    http = FactoryGirl.create(:short_url, url: "https://bbc.co.uk")
    assert_equal "https://bbc.co.uk", http.url
  end

  test "should not be able to save a link with a badly formatted URL" do
    not_a_website = FactoryGirl.build(:short_url, url: "not a website address")
    refute not_a_website.valid?
  end

  test "not_deleted scope should only return short_urls where deleted isn't true" do
    not_deleted_url = FactoryGirl.create(:short_url)
    deleted_url     = FactoryGirl.create(:short_url, deleted: true)

    not_deleted = ShortUrl.not_deleted.to_a
    assert not_deleted.include?(not_deleted_url)
    assert !not_deleted.include?(deleted_url)
  end

  test "should default not_a_robot to true" do
    link = FactoryGirl.create(:short_url, url: 'http://envirobear.com')
    assert_equal true, link.not_a_robot
  end

  test "should not be able to save if non_robot is false" do
    link = FactoryGirl.build(:short_url, url: 'http://envirobear.com', not_a_robot: false)
    refute link.valid?
  end

  test "can create a ShortUrl with a User association" do
    user = FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url, user: user)

    assert_equal user, short_url.user
  end
end
