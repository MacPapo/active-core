require 'rails_helper'

RSpec.describe "memberships/new", type: :view do
  before(:each) do
    assign(:membership, Membership.new(
      active: false,
      subscription_type: nil,
      user: nil
    ))
  end

  it "renders new membership form" do
    render

    assert_select "form[action=?][method=?]", memberships_path, "post" do

      assert_select "input[name=?]", "membership[active]"

      assert_select "input[name=?]", "membership[subscription_type_id]"

      assert_select "input[name=?]", "membership[user_id]"
    end
  end
end
