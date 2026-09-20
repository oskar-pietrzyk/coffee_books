require "rails_helper"

RSpec.describe RentalMailer, type: :mailer do
  it "builds a due-today reminder without external delivery" do
    book = Book.create!(title: "Dune", author: "Frank Herbert")
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    rental = Rental.create!(book: book, reader: reader, duration_date: Date.current)

    email = described_class.expiration_reminder(rental, reminder_type: :due_today)

    expect(email.to).to eq([reader.email])
    expect(email.subject).to eq("Your book is due today")
    expect(email.text_part.body.to_s).to include("is due today")
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end