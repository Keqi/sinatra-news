module PilotNews
  module API
    class Base < Sinatra::Base
      VERSIONS = ["v1", "v2"]

      configure do
        Dotenv.load(".env.#{environment}", '.env')
        ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

        register Sinatra::Namespace
        register Sinatra::RespondWith

        helpers  Sinatra::JSON

        respond_to :json, :xml

        set :raise_errors, true
        set :show_exceptions, :after_handler

        use ActiveRecord::ConnectionAdapters::ConnectionManagement
      end

      error ActiveRecord::RecordNotFound do |e|
        halt 404, e.to_s
      end

      error ActiveRecord::RecordInvalid do |e|
        halt 422, e.to_s
      end

      before %r{/v(\d+)} do
        version = request.fullpath.split("/")[1]
        halt 501, "Version not supported" unless VERSIONS.include?(version)
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
          @auth.provided? and @auth.credentials and @user
        end
      end
    end
  end
end