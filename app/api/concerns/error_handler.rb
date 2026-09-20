module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid do |e|
      error!({ error: 'Record invalid', details: e.record.errors.full_messages }, 422)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({ error: 'Record not found', message: e.message }, 404)
    end
  end
end