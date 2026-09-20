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

  describe "PATCH /v1/books/:uuid" do
    it "borrows a book for an existing reader" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")

      patch "/v1/books/#{book.uuid}", {
        availability_status: "borrowed",
        borrowed_at: "2026-09-20T10:00:00Z",
        reader_uuid: reader.uuid
      }

      expect(last_response).to have_http_status(:ok)
      expect(JSON.parse(last_response.body)).to include("availability_status" => "borrowed")
      expect(book.reload.rentals.active.first.reader).to eq(reader)
    end

    it "creates a reader when borrowing with reader details" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")

      patch "/v1/books/#{book.uuid}", {
        availability_status: "borrowed",
        borrowed_at: "2026-09-20T10:00:00Z",
        full_name: "Ada Lovelace",
        email: "ada@example.com"
      }

      expect(last_response).to have_http_status(:ok)
      expect(Reader.find_by(email: "ada@example.com")).to be_present
    end

    it "returns a book to available and closes its rental" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
      rental = Rental.create!(book: book, reader: reader)
      book.update!(availability_status: :borrowed)

      patch "/v1/books/#{book.uuid}", availability_status: "available"

      expect(last_response).to have_http_status(:ok)
      expect(book.reload).to be_available
      expect(rental.reload).to be_returned
    end

    it "rejects borrowing without rental details" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")

      patch "/v1/books/#{book.uuid}", availability_status: "borrowed"

      expect(last_response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(last_response.body)["details"]).to include("borrowed_at is required")
    end
  end

  describe "GET /v1/books" do
    it "returns a compact serialized list of books" do
      available_book = Book.create!(title: "Dune", author: "Frank Herbert")
      borrowed_book = Book.create!(title: "Foundation", author: "Isaac Asimov")
      borrowed_book.update!(availability_status: :borrowed)

      get "/v1/books", author: ""

      expect(last_response).to have_http_status(:ok)
      response = JSON.parse(last_response.body)

      expect(response["books"]).to contain_exactly(
        include("uuid" => available_book.uuid, "availability_status" => "available"),
        include("uuid" => borrowed_book.uuid, "availability_status" => "borrowed")
      )
      expect(response["pagination"]).to include(
        "page" => 1,
        "per_page" => 20,
        "total_count" => 2,
        "total_pages" => 1
      )
    end

    it "requires title or author search parameters" do
      get "/v1/books"

      expect(last_response).to have_http_status(:bad_request)
    end

    it "filters by partial title and author" do
      matching_book = Book.create!(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin")
      Book.create!(title: "Dune", author: "Frank Herbert")

      get "/v1/books", title: "left hand", author: "le guin"

      expect(last_response).to have_http_status(:ok)
      expect(JSON.parse(last_response.body).fetch("books").pluck("uuid")).to eq([matching_book.uuid])
    end

    it "treats SQL-like search input as a value" do
      Book.create!(title: "Dune", author: "Frank Herbert")

      get "/v1/books", title: "' OR 1=1 --"

      expect(last_response).to have_http_status(:ok)
      expect(JSON.parse(last_response.body)).to eq([])
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

    it "preserves rental history by rejecting deletion after a returned rental" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
      rental = Rental.create!(book: book, reader: reader)
      rental.return!

      delete "/v1/books/#{book.uuid}"

      response = JSON.parse(last_response.body)
      expect(last_response).to have_http_status(:conflict)
      expect(response["error"]).to eq("Book has rental history")
      expect(Book.find_by(id: book.id)).to be_present
      expect(Rental.find_by(id: rental.id)).to be_present
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