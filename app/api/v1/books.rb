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