require "rails_helper"
require "rack/test"

RSpec.describe "Books API", type: :request do
  include Rack::Test::Methods

  def app
    API
  end

  describe "POST /v1/books" do
    it "creates an available book" do
      post "/v1/books", { title: "Dune", author: "Frank Herbert" }

      expect(last_response).to have_http_status(:created)
      expect(JSON.parse(last_response.body)).to include(
        "title" => "Dune",
        "author" => "Frank Herbert",
        "availability_status" => "available"
      )
      expect(Book.find_by!(title: "Dune")).to be_available
    end

    it "requires title and author" do
      post "/v1/books", { title: "Dune" }

      expect(last_response).to have_http_status(:bad_request)
      expect(JSON.parse(last_response.body)["error"]).to include("author is missing")
    end

    it "documents the endpoint in Swagger" do
      get "/v1/swagger_doc"

      swagger = JSON.parse(last_response.body)

      expect(last_response).to have_http_status(:ok)
      expect(swagger.dig("paths", "/v1/books", "post")).to be_present
    end
  end
end