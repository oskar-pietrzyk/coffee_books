class BookBorrowedError < StandardError
  attr_reader :book, :rental, :serialized_book

  def initialize(book:, rental:, serialized_book:)
    @book = book
    @rental = rental
    @serialized_book = serialized_book
    super("Book #{book.uuid} is currently borrowed")
  end
end