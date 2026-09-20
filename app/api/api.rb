class API < Grape::API
  format :json
  include ErrorHandler
  mount V1::Base
end
