# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WaitlistsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/waitlists').to route_to('waitlists#index')
    end

    it 'routes to #new' do
      expect(get: '/waitlists/new').to route_to('waitlists#new')
    end

    it 'routes to #show' do
      expect(get: '/waitlists/1').to route_to('waitlists#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/waitlists/1/edit').to route_to('waitlists#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/waitlists').to route_to('waitlists#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/waitlists/1').to route_to('waitlists#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/waitlists/1').to route_to('waitlists#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/waitlists/1').to route_to('waitlists#destroy', id: '1')
    end
  end
end
