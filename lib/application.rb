require 'active_record'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/router'
require 'json'
require 'dotenv'
require 'base'
require 'stories'
require 'users'
require 'votes'
require_relative 'models/story'
require_relative 'models/user'
require_relative 'models/vote'

module PilotNews
  class Application < Sinatra::Base
    use Sinatra::Router do
      mount Stories
      mount Users
      mount Votes
    end
  end
end