require "rails_helper"

RSpec.describe Reader, type: :model do
  subject(:reader) { described_class.new(full_name: "Ada Lovelace", email: "ada@example.com") }

  it "generates a unique six-digit uuid" do
    reader.save!

    expect(reader.uuid).to match(/\A\d{6}\z/)
  end

  it "requires a unique email" do
    reader.save!
    duplicate = described_class.new(full_name: "Another Reader", email: reader.email)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end

  it "has rentals through user_id" do
    expect(reader).to respond_to(:rentals)
  end
end