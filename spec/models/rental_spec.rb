require "rails_helper"

RSpec.describe Rental, type: :model do
  let(:book) { Book.create!(title: "Dune", author: "Frank Herbert") }
  let(:reader) { Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com") }

  it "defaults to a 30-day borrowed rental" do
    rental = described_class.create!(book: book, reader: reader)

    expect(rental.reading_status).to eq("borrowed")
    expect(rental.borrowed_at.to_date + 30.days).to eq(rental.duration_date)
    expect(rental.returned_at).to be_nil
  end

  it "associates the reader through user_id" do
    rental = described_class.create!(book: book, reader: reader)

    expect(rental.user_id).to eq(reader.id)
    expect(rental.reader).to eq(reader)
  end

  it "returns a rental and makes its book available" do
    rental = described_class.create!(book: book, reader: reader)
    book.update!(availability_status: "borrowed")

    rental.return!

    expect(rental.reload.reading_status).to eq("returned")
    expect(rental.returned_at).to be_present
    expect(book.reload.availability_status).to eq("available")
  end

  it "supports active rental lookups by due date" do
    rental = described_class.create!(book: book, reader: reader, duration_date: Date.current + 3.days)

    expect(described_class.active.where(duration_date: Date.current + 3.days)).to contain_exactly(rental)
  end

  it "accepts only borrowed or returned reading statuses" do
    expect { described_class.new(reading_status: "lost") }.to raise_error(ArgumentError)
  end
end