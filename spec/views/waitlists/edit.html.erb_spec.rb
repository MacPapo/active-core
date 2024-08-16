# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'waitlists/edit', type: :view do
  let(:waitlist) do
    Waitlist.create!(
      user: nil,
      activity: nil
    )
  end

  before(:each) do
    assign(:waitlist, waitlist)
  end

  it 'renders the edit waitlist form' do
    render

    assert_select 'form[action=?][method=?]', waitlist_path(waitlist), 'post' do
      assert_select 'input[name=?]', 'waitlist[user_id]'

      assert_select 'input[name=?]', 'waitlist[activity_id]'
    end
  end
end
