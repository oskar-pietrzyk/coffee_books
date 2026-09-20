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
      expect(swagger.dig("paths", "/v1/books/{uuid}", "get")).to be_present
    end
  end

  describe "GET /v1/books/:uuid" do
    it "returns one serialized book with rental history by uuid" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
      rental = Rental.create!(book: book, reader: reader)
      book.update!(availability_status: :borrowed)

      get "/v1/books/#{book.uuid}"

      response = JSON.parse(last_response.body)

      expect(last_response).to have_http_status(:ok)
      expect(response).to include(
        "uuid" => book.uuid,
        "title" => book.title,
        "author" => book.author,
        "availability_status" => "borrowed"
      )
      expect(response["rentals"]).to include(
        include(
          "id" => rental.id,
          "reading_status" => "borrowed",
          "reader" => include(
            "uuid" => reader.uuid,
            "full_name" => reader.full_name,
            "email" => reader.email
          )
        )
      )
    end

    it "returns not found for an unknown uuid" do
      get "/v1/books/999999"

      expect(last_response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /v1/books/:uuid" do
    it "deletes an available book" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")

      delete "/v1/books/#{book.uuid}"

      expect(last_response).to have_http_status(:ok)
      expect(JSON.parse(last_response.body)).to include(
        "message" => "Book deleted",
        "book" => include(
          "uuid" => book.uuid,
          "title" => book.title,
          "author" => book.author,
          "availability_status" => "available"
        )
      )
      expect(Book.find_by(id: book.id)).to be_nil
    end

    it "returns reader details when the book is borrowed" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
      Rental.create!(book: book, reader: reader)
      book.update!(availability_status: :borrowed)

      delete "/v1/books/#{book.uuid}"

      response = JSON.parse(last_response.body)
      expect(last_response).to have_http_status(:conflict)
      expect(response).to include("error" => "Book borrowed")
      expect(response["book"]).to include(
        "uuid" => book.uuid,
        "availability_status" => "borrowed",
        "rentals" => include(
          include(
            "reading_status" => "borrowed",
            "reader" => include("uuid" => reader.uuid)
          )
        )
      )
      expect(response["reader"]).to include(
        "uuid" => reader.uuid,
        "full_name" => reader.full_name,
        "email" => reader.email
      )
    end

    it "returns not found for an unknown book" do
      delete "/v1/books/999999"

      expect(last_response).to have_http_status(:not_found)
    end

    it "uses uuid when books have the same title and author" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      duplicate = Book.create!(title: book.title, author: book.author)

      delete "/v1/books/#{book.uuid}"

      expect(last_response).to have_http_status(:ok)
      expect(Book.find_by(id: book.id)).to be_nil
      expect(Book.find_by(id: duplicate.id)).to be_present
    end
  end
end