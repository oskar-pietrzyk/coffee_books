module V1
  class Base < Grape::API
    version 'v1', using: :path
    format :json

    get :health_check do
      { status: 'ok' }
    end

    mount Books

    add_swagger_documentation(
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: '/swagger_doc',
      hide_format: true
    )
  end
end
