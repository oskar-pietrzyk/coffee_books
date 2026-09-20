class UpdateBook < ApplicationService
  attr_reader :uuid, :availability_status, :borrowed_at, :duration_date, :reader_uuid, :full_name, :email

  def initialize(uuid:, availability_status:, borrowed_at: nil, duration_date: nil, reader_uuid: nil, full_name: nil, email: nil)
    @uuid = uuid
    @availability_status = availability_status
    @borrowed_at = borrowed_at
    @duration_date = duration_date
    @reader_uuid = reader_uuid
    @full_name = full_name
    @email = email
  end

  def call
    book = Book.find_by!(uuid: uuid)

    case availability_status
    when "available"
      ReturnBook.call(book: book)
    when "borrowed"
      BorrowBook.call(
        book: book,
        borrowed_at: borrowed_at,
        duration_date: duration_date,
        reader_uuid: reader_uuid,
        full_name: full_name,
        email: email
      )
    end

    book
  end
end