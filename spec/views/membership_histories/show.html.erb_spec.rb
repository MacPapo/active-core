require 'rails_helper'

RSpec.describe "membership_histories/show", type: :view do
  before(:each) do
    assign(:membership_history, MembershipHistory.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
