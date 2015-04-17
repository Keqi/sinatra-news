module PilotNews
  class Users < Base
    put '/users' do
      status 201 if User.create!(params[:user])
    end
  end
end