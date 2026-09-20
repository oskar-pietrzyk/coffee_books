class IndexBooks < ApplicationService
  Result = Struct.new(:books, :page, :per_page, :total_count, keyword_init: true)
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  attr_reader :title, :author, :page, :per_page

  def initialize(title: nil, author: nil, page: 1, per_page: DEFAULT_PER_PAGE)
    @title = title
    @author = author
    @page = [page.to_i, 1].max
    @per_page = [[per_page.to_i, 1].max, MAX_PER_PAGE].min
  end

  def call
    books = Book.all
    books = books.where("title ILIKE ?", "%#{quoted_filter(title)}%") if title.present?
    books = books.where("author ILIKE ?", "%#{quoted_filter(author)}%") if author.present?
    books = books.order(created_at: :desc, id: :desc)

    Result.new(
      books: books.limit(per_page).offset((page - 1) * per_page),
      page: page,
      per_page: per_page,
      total_count: books.count
    )
  end

  private

  def quoted_filter(value)
    ActiveRecord::Base.sanitize_sql_like(value)
  end
end