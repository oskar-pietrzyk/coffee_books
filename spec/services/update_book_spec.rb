require "rails_helper"

RSpec.describe UpdateBook do
  let(:book) { Book.create!(title: "Dune", author: "Frank Herbert") }
  let(:borrowed_at) { Time.zone.parse("2026-09-20 10:00:00") }

  it "borrows an available book for an existing reader" do
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")

    described_class.call(uuid: book.uuid, availability_status: "borrowed", borrowed_at: borrowed_at, reader_uuid: reader.uuid)

    expect(book.reload).to be_borrowed
    expect(book.rentals.active.first.reader).to eq(reader)
    expect(book.rentals.active.first.duration_date).to eq(borrowed_at.to_date + 30.days)
  end

  it "creates a reader when borrowing without reader_uuid" do
    described_class.call(
      uuid: book.uuid,
      availability_status: "borrowed",
      borrowed_at: borrowed_at,
      full_name: "Ada Lovelace",
      email: "ada@example.com"
    )

    expect(Reader.find_by(email: "ada@example.com")).to be_present
    expect(book.reload).to be_borrowed
  end

  it "returns a borrowed book and closes its active rental" do
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    rental = Rental.create!(book: book, reader: reader, borrowed_at: borrowed_at)
    book.update!(availability_status: :borrowed)

    described_class.call(uuid: book.uuid, availability_status: "available")

    expect(book.reload).to be_available
    expect(rental.reload).to be_returned
    expect(rental.returned_at).to be_present
  end

  it "rejects borrowing without date and reader information" do
    error = catch_error { described_class.call(uuid: book.uuid, availability_status: "borrowed") }

    expect(error).to be_a(InvalidBookStatusUpdate)
    expect(error.details).to include("borrowed_at is required")
    expect(error.details).to include("reader_uuid, full_name, and email are required")
  end

  it "does not allow borrowing an already borrowed book" do
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    Rental.create!(book: book, reader: reader, borrowed_at: borrowed_at)
    book.update!(availability_status: :borrowed)

    expect {
      described_class.call(uuid: book.uuid, availability_status: "borrowed", borrowed_at: borrowed_at, reader_uuid: reader.uuid)
    }.to raise_error(InvalidBookStatusUpdate, /already borrowed/)
  end

  private

  def catch_error
    yield
  rescue StandardError => error
    error
  end
end