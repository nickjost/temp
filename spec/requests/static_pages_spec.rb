require 'rails_helper'

RSpec.describe "StaticPages", :type => :request do
  describe "GET /" do
    it "returns a page and status 200" do
      get "/"
      expect(response).to have_http_status(200)
    end
  end
end
