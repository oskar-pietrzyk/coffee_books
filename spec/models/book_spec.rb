require "rails_helper"

RSpec.describe Book, type: :model do
  subject(:book) { described_class.new(title: "Dune", author: "Frank Herbert") }

  it "generates a unique six-digit uuid" do
    book.save!

    expect(book.uuid).to match(/\A\d{6}\z/)
  end

  it "defaults to available" do
    expect(book.availability_status).to eq("available")
  end

  it "accepts only borrowed or available statuses" do
    expect { book.availability_status = "lost" }.to raise_error(ArgumentError)
  end

  it "has rental history" do
    expect(book).to respond_to(:rentals)
  end
end