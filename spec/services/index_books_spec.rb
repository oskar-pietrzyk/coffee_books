require "rails_helper"

RSpec.describe IndexBooks do
  it "returns newest matching books first" do
    first_book = Book.create!(title: "Dune", author: "Frank Herbert")
    second_book = Book.create!(title: "Foundation", author: "Isaac Asimov")

    result = described_class.call(title: "")

    expect(result.books).to eq([second_book, first_book])
    expect(result.total_count).to eq(2)
  end

  it "filters title and author with partial case-insensitive matches" do
    matching_book = Book.create!(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin")
    Book.create!(title: "Dune", author: "Frank Herbert")

    expect(described_class.call(title: "left hand", author: "LE GUIN").books).to eq([matching_book])
  end

  it "paginates results" do
    books = 3.times.map { |index| Book.create!(title: "Book #{index}", author: "Author") }

    result = described_class.call(author: "Author", page: 2, per_page: 2)

    expect(result.books).to eq([books.first])
    expect(result.page).to eq(2)
    expect(result.per_page).to eq(2)
    expect(result.total_count).to eq(3)
  end

end