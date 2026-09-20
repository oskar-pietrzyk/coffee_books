class RentalMailer < ApplicationMailer
  def expiration_reminder(rental, reminder_type:)
    @rental = rental
    @reminder_type = reminder_type.to_sym

    Rails.logger.info(
      {
        event: "rental_expiration_reminder",
        reminder_type: @reminder_type,
        rental_id: rental.id,
        book_uuid: rental.book.uuid,
        reader_email: rental.reader.email,
        duration_date: rental.duration_date
      }.to_json
    )

    mail(
      to: rental.reader.email,
      subject: @reminder_type == :due_today ? "Your book is due today" : "Your book is due in 3 days"
    )
  end
end