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
      availability_status: book.availability_status
    }
  end
end