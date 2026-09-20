class BookSerializer
  attr_reader :book

  def self.serialize(book)
    new(book).serialize
  end

  def initialize(book)
    @book = book
  end

  def serialize
    {
      id: book.id,
      uuid: book.uuid,
      title: book.title,
      author: book.author,
      availability_status: book.availability_status,
      rentals: book.rentals.includes(:reader).order(:borrowed_at).map do |rental|
        {
          id: rental.id,
          duration_date: rental.duration_date,
          borrowed_at: rental.borrowed_at,
          returned_at: rental.returned_at,
          reading_status: rental.reading_status,
          reader: {
            id: rental.reader.id,
            uuid: rental.reader.uuid,
            full_name: rental.reader.full_name,
            email: rental.reader.email
          }
        }
      end
    }
  end
end