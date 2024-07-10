require "rails_helper"

RSpec.describe MembershipHistoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/membership_histories").to route_to("membership_histories#index")
    end

    it "routes to #new" do
      expect(get: "/membership_histories/new").to route_to("membership_histories#new")
    end

    it "routes to #show" do
      expect(get: "/membership_histories/1").to route_to("membership_histories#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/membership_histories/1/edit").to route_to("membership_histories#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/membership_histories").to route_to("membership_histories#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/membership_histories/1").to route_to("membership_histories#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/membership_histories/1").to route_to("membership_histories#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/membership_histories/1").to route_to("membership_histories#destroy", id: "1")
    end
  end
end
