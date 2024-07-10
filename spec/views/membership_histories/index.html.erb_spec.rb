require 'rails_helper'

RSpec.describe "membership_histories/index", type: :view do
  before(:each) do
    assign(:membership_histories, [
      MembershipHistory.create!(),
      MembershipHistory.create!()
    ])
  end

  it "renders a list of membership_histories" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
  end
end
