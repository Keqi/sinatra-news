require 'active_record'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/router'
require 'json'
require 'dotenv'
require_relative 'api/v1/base'
require_relative 'api/v1/stories'
require_relative 'api/v1/users'
require_relative 'api/v1/votes'

require_relative 'api/v2/base'
require_relative 'api/v2/stories'
require_relative 'api/v2/users'
require_relative 'api/v2/votes'

require_relative 'models/story'
require_relative 'models/user'
require_relative 'models/vote'

module PilotNews
  class Application < Sinatra::Base
    use Sinatra::Router do
      mount API::V1::Stories
      mount API::V1::Users
      mount API::V1::Votes

      mount API::V2::Stories
      mount API::V2::Users
      mount API::V2::Votes
    end
  end
end