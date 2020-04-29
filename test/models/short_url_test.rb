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

    bt = FactoryGirl.create(:organization, name: 'BT')
    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: bt
    )

    create_disregard_votes(bt)

    virgin_media = FactoryGirl.create(:organization, name: 'Virgin Media')
    FactoryGirl.create(:visit,
      short_url: @short_url,
      organization: virgin_media
    )

    FactoryGirl.create(:organization, name: 'Plusnet')

    create_disregard_votes(virgin_media, 5)
  end

  def create_disregard_votes(organization, count=1)
    (1..count).each do
      FactoryGirl.create(:disregard_vote, organization: organization)
    end
  end

  test "ordered_by_visits_desc scope orders by visit count" do
    bbc_short_url = FactoryGirl.create(:short_url, url: "http://bbc.co.uk")
    (1..20).each do
      FactoryGirl.create(:visit, short_url: bbc_short_url)
    end

    short_urls = ShortUrl.ordered_by_visits_desc

    assert_equal bbc_short_url, short_urls.first
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
    2.times do
      FactoryGirl.create(:visit, short_url: @short_url, city: FactoryGirl.create(:city))
    end

    country_stats = @short_url.visits_by_country
    assert_equal 2, country_stats["Canada"]
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

  test "visits_by_organization with group_by_disregarded = true
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
    assert_nil counts[:pertinent]["Virgin Media"]
    assert_nil counts[:pertinent]["Plusnet"]
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

  test "should sanitise a custom short_name on save" do
    original_short_name = "this  is a ??very_bad@£$^/short.,.name cinématographique"
    sanitised_short_name = "this_is_a_very_bad_short_name_cinématographique"

    custom_short_url = FactoryGirl.create(:short_url, short_name: original_short_name)
    assert_equal sanitised_short_name, custom_short_url.short_name
  end

  test "not_deleted scope should only return short_urls where deleted isn't true" do
    not_deleted_url = FactoryGirl.create(:short_url)
    deleted_url     = FactoryGirl.create(:short_url, deleted: true)

    not_deleted = ShortUrl.not_deleted.to_a
    assert not_deleted.include?(not_deleted_url)
    assert !not_deleted.include?(deleted_url)
  end

  test "can create a ShortUrl with a User association" do
    user = FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url, user: user)

    assert_equal user, short_url.user
  end

  test ".owned_by? returns true if the ShortUrl is owned by the user" do
    user = FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url, user: user)
    assert_equal true, short_url.owned_by?(user)
  end

  test ".owned_by? returns false if the ShortUrl is not owned by the user" do
    user = FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url)
    assert_equal false, short_url.owned_by?(user)
  end
end
