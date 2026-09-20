class IndexBooks < ApplicationService
  attr_reader :title, :author

  def initialize(title: nil, author: nil)
    @title = title
    @author = author
  end

  def call
    books = Book.all
    books = books.where("title ILIKE ?", "%#{quoted_filter(title)}%") if title.present?
    books = books.where("author ILIKE ?", "%#{quoted_filter(author)}%") if author.present?
    books.order(created_at: :desc, id: :desc)
  end

  private

  def quoted_filter(value)
    ActiveRecord::Base.sanitize_sql_like(value)
  end
end