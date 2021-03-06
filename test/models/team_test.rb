require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test 'team with name is valid' do
    team = FactoryGirl.build(:team, name: 'Informatics')
    assert_equal true, team.valid?
  end

  test 'team without name is invalid' do
    team = FactoryGirl.build(:team, name: nil)
    assert_equal false, team.valid?
  end

  test 'destroying a team with users does not destroy users' do
    team = FactoryGirl.create(:team)
    user = FactoryGirl.create(:user, team: team)
    team.destroy
    assert_not_nil user.reload
  end
end
