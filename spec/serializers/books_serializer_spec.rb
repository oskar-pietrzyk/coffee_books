require "rails_helper"

RSpec.describe BooksSerializer do
  it "serializes compact book list data" do
    books = [
      Book.new(uuid: "100001", title: "Dune", author: "Frank Herbert"),
      Book.new(uuid: "100002", title: "Foundation", author: "Isaac Asimov", availability_status: :borrowed)
    ]

    expect(described_class.serialize(books)).to eq([
      {
        uuid: "100001",
        title: "Dune",
        author: "Frank Herbert",
        availability_status: "available"
      },
      {
        uuid: "100002",
        title: "Foundation",
        author: "Isaac Asimov",
        availability_status: "borrowed"
      }
    ])
  end
end