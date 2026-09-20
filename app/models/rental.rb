class Rental < ApplicationRecord
  DEFAULT_DURATION_DAYS = 30

  belongs_to :book
  belongs_to :reader, foreign_key: :user_id

  before_validation :set_defaults, on: :create

  enum :reading_status, { borrowed: "borrowed", returned: "returned" }

  validates :duration_date, :borrowed_at, presence: true
  validates :returned_at, presence: true, if: -> { reading_status == "returned" }
  validates :returned_at, absence: true, if: -> { reading_status == "borrowed" }

  scope :active, -> { where(reading_status: "borrowed") }

  def return!
    ReturnBook.call(book: book)
  end

  private

  def set_defaults
    self.borrowed_at ||= Time.current
    self.duration_date ||= borrowed_at.to_date + DEFAULT_DURATION_DAYS.days
    self.reading_status ||= "borrowed"
  end
end