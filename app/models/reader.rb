class Reader < ApplicationRecord
  has_many :rentals, foreign_key: :user_id, dependent: :destroy

  before_validation :assign_uuid, on: :create

  validates :uuid, format: { with: /\A\d{6}\z/ }, uniqueness: true
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def assign_uuid
    self.uuid ||= loop do
      candidate = format("%06d", SecureRandom.random_number(1_000_000))
      break candidate unless Reader.exists?(uuid: candidate)
    end
  end
end