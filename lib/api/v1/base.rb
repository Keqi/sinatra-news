module PilotNews
  module API
    module V1
      class Base < Sinatra::Base
        configure do
          Dotenv.load(".env.#{environment}", '.env')
          ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

          register Sinatra::Namespace
          register Sinatra::RespondWith

          helpers  Sinatra::JSON

          respond_to :json, :xml

          use ActiveRecord::ConnectionAdapters::ConnectionManagement
        end

        error ActiveRecord::RecordNotFound do
          halt 404, "Resource not found."
        end

        helpers do
          def protected!
            return if authorized?
            headers['WWW-Authenticate'] = 'Restricted Area'
            halt 401, "Not authorized\n"
          end

          def authorized?
            @auth ||=  Rack::Auth::Basic::Request.new(request.env)
            @user = User.where(username: @auth.credentials.first, password: @auth.credentials.last).first
            @auth.provided? and @auth.basic? and @auth.credentials and @user
          end
        end
      end
    end
  end
end