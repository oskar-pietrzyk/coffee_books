class ShowBook < ApplicationService
  attr_reader :uuid

  def initialize(uuid:)
    @uuid = uuid
  end

  def call
    Book.includes(rentals: :reader).find_by!(uuid: uuid)
  end
end