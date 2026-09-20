class RentalExpirationJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform(today = Date.current.to_s)
    current_date = Date.parse(today.to_s)

    process_due_rentals(current_date + 3.days, :reminder_sent_at, :due_soon)
    process_due_rentals(current_date, :due_reminder_sent_at, :due_today)
  end

  private

  def process_due_rentals(duration_date, sent_column, reminder_type)
    Rental.active
      .where(duration_date: duration_date, sent_column => nil)
      .find_each do |rental|
        next unless claim_reminder(rental, sent_column)

        RentalMailer.expiration_reminder(rental, reminder_type: reminder_type).deliver_later
      end
  end

  def claim_reminder(rental, sent_column)
    Rental
      .where(id: rental.id, reading_status: :borrowed, sent_column => nil)
      .update_all(sent_column => Time.current) == 1
  end
end