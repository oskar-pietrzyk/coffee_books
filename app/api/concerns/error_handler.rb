module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      error!({ error: 'Record invalid', details: e.record.errors.full_messages }, 422)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({ error: 'Record not found', message: e.message }, 404)
    end

    rescue_from ::InvalidBookStatusUpdate do |e|
      error!({ error: 'Invalid book status update', details: e.details }, 422)
    end

    rescue_from ::BookBorrowedError do |e|
      rental = e.rental
      reader = rental&.reader

      error!({
        error: 'Book borrowed',
        message: e.message,
        book: e.serialized_book,
        reader: reader && {
          id: reader.id,
          uuid: reader.uuid,
          full_name: reader.full_name,
          email: reader.email
        },
        return_date: rental&.duration_date
      }, 409)
    end

  end
end