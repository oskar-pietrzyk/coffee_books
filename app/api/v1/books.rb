module V1
  class Books < Grape::API
    resource :books do
      desc 'Create a book', success: { code: 201, message: 'Book created' }
      params do
        requires :title, type: String, desc: 'Book title'
        requires :author, type: String, desc: 'Book author'
      end
      post do
        book = ::CreateBook.call(title: params[:title], author: params[:author])

        status 201
        BookSerializer.serialize(book)
      end

      desc 'List books', success: { code: 200, message: 'Books found' }
      params do
        optional :title, type: String, desc: 'Partial book title filter'
        optional :author, type: String, desc: 'Partial book author filter'
      end
      get do
        BooksSerializer.serialize(::IndexBooks.call(
          title: params[:title],
          author: params[:author]
        ))
      end

      desc 'Show a book by uuid', success: { code: 200, message: 'Book found' }
      params do
        requires :uuid, type: String, desc: 'Book public identifier'
      end
      get ':uuid' do
        book = ::ShowBook.call(uuid: params[:uuid])

        BookSerializer.serialize(book)
      end

      desc 'Update book availability and its rental state', success: { code: 200, message: 'Book updated' }
      params do
        requires :uuid, type: String, desc: 'Book public identifier'
        requires :availability_status, type: String, values: %w[available borrowed]
        optional :borrowed_at, type: DateTime, desc: 'Borrowing date and time'
        optional :duration_date, type: Date, desc: 'Return date; defaults to 30 days after borrowing'
        optional :reader_uuid, type: String, desc: 'Existing reader public identifier'
        optional :full_name, type: String, desc: 'New reader full name'
        optional :email, type: String, desc: 'New reader email'
      end
      patch ':uuid' do
        book = ::UpdateBook.call(
          uuid: params[:uuid],
          availability_status: params[:availability_status],
          borrowed_at: params[:borrowed_at],
          duration_date: params[:duration_date],
          reader_uuid: params[:reader_uuid],
          full_name: params[:full_name],
          email: params[:email]
        )

        BookSerializer.serialize(book)
      end

      desc 'Delete an available book', success: { code: 200, message: 'Book deleted' }
      params do
        requires :uuid, type: String, desc: 'Book public identifier'
      end
      delete ':uuid' do
        deleted_book = ::DeleteBook.call(uuid: params[:uuid])

        deleted_book
      end
    end
  end
end