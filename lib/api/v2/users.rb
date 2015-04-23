module PilotNews
  module API
    module V2
      class Users < Base
        namespace '/v2' do
          put '/users' do
            if user = User.create!(params[:user])
              status 201
              respond_with user
            end
          end
        end
      end
    end
  end
end