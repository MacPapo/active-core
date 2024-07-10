require 'rails_helper'

RSpec.describe "membership_histories/new", type: :view do
  before(:each) do
    assign(:membership_history, MembershipHistory.new())
  end

  it "renders new membership_history form" do
    render

    assert_select "form[action=?][method=?]", membership_histories_path, "post" do
    end
  end
end
