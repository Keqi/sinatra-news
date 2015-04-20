module PilotNews
  module API
    module V1
      class Users < Base
        namespace '/v1' do
          put '/users' do
            status 201 if User.create!(params[:user])
          end
        end
      end
    end
  end
end