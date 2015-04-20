module PilotNews
  module API
    module V2
      class Users < Base
        namespace '/v2' do
          put '/users' do
            status 201 if User.create!(params[:user])
          end
        end
      end
    end
  end
end