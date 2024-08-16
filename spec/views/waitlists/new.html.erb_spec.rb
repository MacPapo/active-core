# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'waitlists/new', type: :view do
  before(:each) do
    assign(:waitlist, Waitlist.new(
                        user: nil,
                        activity: nil
                      ))
  end

  it 'renders new waitlist form' do
    render

    assert_select 'form[action=?][method=?]', waitlists_path, 'post' do
      assert_select 'input[name=?]', 'waitlist[user_id]'

      assert_select 'input[name=?]', 'waitlist[activity_id]'
    end
  end
end
