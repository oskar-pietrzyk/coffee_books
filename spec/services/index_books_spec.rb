require "rails_helper"

RSpec.describe IndexBooks do
  it "returns newest matching books first" do
    first_book = Book.create!(title: "Dune", author: "Frank Herbert")
    second_book = Book.create!(title: "Foundation", author: "Isaac Asimov")

    expect(described_class.call(title: "")).to eq([second_book, first_book])
  end

  it "filters title and author with partial case-insensitive matches" do
    matching_book = Book.create!(title: "The Left Hand of Darkness", author: "Ursula K. Le Guin")
    Book.create!(title: "Dune", author: "Frank Herbert")

    expect(described_class.call(title: "left hand", author: "LE GUIN")).to eq([matching_book])
  end

end