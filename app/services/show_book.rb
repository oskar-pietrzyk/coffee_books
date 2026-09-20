class ShowBook < ApplicationService
  def initialize(uuid:)
    @uuid = uuid
  end

  def call
    Book.includes(rentals: :reader).find_by!(uuid: @uuid)
  end
end