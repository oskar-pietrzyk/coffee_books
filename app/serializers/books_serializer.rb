class BooksSerializer
  attr_reader :books

  def self.serialize(books)
    new(books).serialize
  end

  def initialize(books)
    @books = books
  end

  def serialize
    books.map do |book|
      {
        uuid: book.uuid,
        title: book.title,
        author: book.author,
        availability_status: book.availability_status
      }
    end
  end
end