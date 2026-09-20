class BookHasRentalHistoryError < StandardError
  attr_reader :book, :serialized_book

  def initialize(book:, serialized_book:)
    @book = book
    @serialized_book = serialized_book
    super("Book #{book.uuid} has rental history and cannot be deleted")
  end
end