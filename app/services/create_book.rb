class CreateBook < ApplicationService
  def initialize(title:, author:)
    @title = title
    @author = author
  end

  def call
    Book.create!(
      title: @title,
      author: @author,
      availability_status: :available
    )
  end
end