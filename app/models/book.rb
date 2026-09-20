class Book < ApplicationRecord
  has_many :rentals, dependent: :restrict_with_error

  scope :active, -> { where(archived: false) }

  before_validation :assign_uuid, on: :create

  enum :availability_status, { borrowed: "borrowed", available: "available" }

  validates :uuid, format: { with: /\A\d{6}\z/ }, uniqueness: true
  validates :title, :author, presence: true

  private

  def assign_uuid
    self.uuid ||= loop do
      candidate = format("%06d", SecureRandom.random_number(1_000_000))
      break candidate unless Book.exists?(uuid: candidate)
    end
  end
end