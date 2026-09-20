require "rails_helper"

RSpec.describe ShowBook do
  let!(:book) { Book.create!(title: "Dune", author: "Frank Herbert") }

  it "finds a book by uuid" do
    expect(described_class.call(uuid: book.uuid)).to eq(book)
  end

  it "raises RecordNotFound for an unknown uuid" do
    expect {
      described_class.call(uuid: "999999")
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end