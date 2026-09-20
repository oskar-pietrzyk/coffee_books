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
        RentalMailer.expiration_reminder(rental, reminder_type: reminder_type).deliver_later
        rental.update!(sent_column => Time.current)
      end
  end
end