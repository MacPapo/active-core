require 'rails_helper'

RSpec.describe "membership_histories/edit", type: :view do
  let(:membership_history) {
    MembershipHistory.create!()
  }

  before(:each) do
    assign(:membership_history, membership_history)
  end

  it "renders the edit membership_history form" do
    render

    assert_select "form[action=?][method=?]", membership_history_path(membership_history), "post" do
    end
  end
end
