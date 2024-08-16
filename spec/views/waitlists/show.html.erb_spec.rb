# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'waitlists/show', type: :view do
  before(:each) do
    assign(:waitlist, Waitlist.create!(
                        user: nil,
                        activity: nil
                      ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
