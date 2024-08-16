# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'waitlists/index', type: :view do
  before(:each) do
    assign(:waitlists, [
             Waitlist.create!(
               user: nil,
               activity: nil
             ),
             Waitlist.create!(
               user: nil,
               activity: nil
             )
           ])
  end

  it 'renders a list of waitlists' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
