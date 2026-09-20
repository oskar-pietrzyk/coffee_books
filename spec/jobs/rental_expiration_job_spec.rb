require "rails_helper"

RSpec.describe RentalExpirationJob do
  include ActiveJob::TestHelper

  let(:today) { Date.new(2026, 9, 20) }
  let(:reader) { Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com") }

  around do |example|
    clear_enqueued_jobs
    clear_performed_jobs
    example.run
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it "enqueues one reminder for rentals due in three days and one due today" do
    due_soon = create_rental(duration_date: today + 3.days)
    due_today = create_rental(duration_date: today)
    create_rental(duration_date: today + 3.days, reminder_sent_at: Time.current)

    described_class.new.perform(today.to_s)

    expect(enqueued_jobs.size).to eq(2)
    expect(due_soon.reload.reminder_sent_at).to be_present
    expect(due_soon.due_reminder_sent_at).to be_nil
    expect(due_today.reload.due_reminder_sent_at).to be_present
  end

  it "does not enqueue duplicate reminders" do
    rental = create_rental(duration_date: today + 3.days, reminder_sent_at: Time.current)

    described_class.new.perform(today.to_s)

    expect(enqueued_jobs).to be_empty
    expect(rental.reload.reminder_sent_at).to be_present
  end

  private

  def create_rental(attributes = {})
    book = Book.create!(title: "Dune #{SecureRandom.hex(3)}", author: "Frank Herbert")
    Rental.create!({ book: book, reader: reader, **attributes })
  end
end