require "rails_helper"

RSpec.describe CreateBook do
  describe ".call" do
    it "creates an available book from the required attributes" do
      book = described_class.call(title: "Dune", author: "Frank Herbert")

      expect(book).to be_persisted
      expect(book.title).to eq("Dune")
      expect(book.author).to eq("Frank Herbert")
      expect(book).to be_available
    end

    it "does not persist an invalid book" do
      expect {
        described_class.call(title: "", author: "Frank Herbert")
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(Book.count).to eq(0)
    end
  end
end