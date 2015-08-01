require 'active_record'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/router'
require 'sinatra/cross_origin'
require 'dalli'
require 'rack-cache'
require 'json'
require 'dotenv'
require 'kaminari/sinatra'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'rack/accept'

require_relative 'api/base'

require_relative 'api/v1/stories'
require_relative 'api/v1/users'
require_relative 'api/v1/votes'

require_relative 'api/v2/stories'
require_relative 'api/v2/users'
require_relative 'api/v2/votes'

require_relative 'models/story'
require_relative 'models/user'
require_relative 'models/vote'
require_relative 'models/board'

module PilotNews
  class Application < Sinatra::Base
    use Sinatra::Router do
      # with_conditions(lambda { e["HTTP_ACCEPT"].include?("v1") }) do
        mount API::V1::Stories
        mount API::V1::Users
        mount API::V1::Votes
      # end

      # with_conditions(lambda { |e| e["HTTP_ACCEPT"].include?("v2") }) do
        mount API::V2::Stories
        mount API::V2::Users
        mount API::V2::Votes
      # end
    end
  end
end