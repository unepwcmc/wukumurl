require 'test_helper'

class DisregardVoteTest < ActiveSupport::TestCase
  test "can create a DisregardVote model with Organization and ShortUrl associations" do
    short_url = FactoryGirl.create(:short_url)
    organization = FactoryGirl.create(:organization)

    disregard_vote = FactoryGirl.create(:disregard_vote,
      organization: organization, short_url: short_url)

    assert_equal organization, disregard_vote.organization
    assert_equal short_url, disregard_vote.short_url
  end
end
