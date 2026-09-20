class BorrowBook < ApplicationService
  attr_reader :book, :borrowed_at, :duration_date, :reader_uuid, :full_name, :email

  def initialize(book:, borrowed_at:, duration_date: nil, reader_uuid: nil, full_name: nil, email: nil)
    @book = book
    @borrowed_at = borrowed_at
    @duration_date = duration_date
    @reader_uuid = reader_uuid
    @full_name = full_name
    @email = email
  end

  def call
    book.with_lock do
      validate_book_state

      reader = find_or_create_reader
      rental = book.rentals.create!(
        reader: reader,
        borrowed_at: borrowed_at,
        duration_date: duration_date
      )
      book.update!(availability_status: :borrowed)
      rental
    end
  end

  private

  def validate_book_state
    errors = []
    errors << "book is already borrowed" if book.borrowed?
    errors << "borrowed_at is required" if borrowed_at.blank?
    errors << "reader_uuid, full_name, and email are required" if reader_uuid.blank? && (full_name.blank? || email.blank?)
    raise InvalidBookStatusUpdate, errors if errors.any?
  end

  def find_or_create_reader
    return Reader.find_by!(uuid: reader_uuid) if reader_uuid.present?

    Reader.create!(full_name: full_name, email: email)
  end
end