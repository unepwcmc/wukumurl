require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  def setup
    @request.env['HTTP_REFERER'] = '/'
  end

  test "DELETE :destroy marks an Organisation as disregarded via
    DisregardVote, but does not delete it" do
    organization = FactoryGirl.create(:organization)

    assert_equal 0, organization.disregard_votes.count
    assert_equal 1, Organization.count

    delete :destroy, id: organization.id
    assert_response :redirect

    organization.reload

    assert_equal 1, organization.disregard_votes.count,
      "Expected Organization disregard count to be 1, but is
      \"#{organization.disregard_votes.count}\""
    assert_equal 1, Organization.count
  end

  test "DELETE :destroy creates a DisregardVote associated to the
    supplied ShortUrl" do
    organization = FactoryGirl.create(:organization)
    short_url = FactoryGirl.create(:short_url)

    delete :destroy, id: organization.id, short_url_id: short_url.id
    assert_response :redirect

    disregard_vote = DisregardVote.last
    assert_equal short_url, disregard_vote.short_url
  end
end
