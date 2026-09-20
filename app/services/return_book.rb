class ReturnBook < ApplicationService
  attr_reader :book

  def initialize(book:)
    @book = book
  end

  def call
    book.with_lock do
      raise InvalidBookStatusUpdate, ["book is archived"] if book.archived?

      rental = book.rentals.active.first
      raise InvalidBookStatusUpdate, ["book has no active rental to return"] unless rental

      rental.update!(reading_status: :returned, returned_at: Time.current)
      book.update!(availability_status: :available)
      rental
    end
  end
end