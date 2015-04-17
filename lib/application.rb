require 'active_record'
require 'sinatra'
require 'json'
require 'dotenv'
require_relative 'models/story'
require_relative 'models/user'
require_relative 'models/vote'

module PilotNews
  class Application < Sinatra::Base
    configure do
      Dotenv.load(".env.#{environment}", '.env')
      ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

      use ActiveRecord::ConnectionAdapters::ConnectionManagement
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

    get '/stories' do
      Story.all.to_json
    end

    get '/stories/:id' do
      Story.find(params[:id]).to_json
    end

    put '/story' do
      protected!
      story = Story.new(params[:story])
      story.user = @user
      story.save!
      status 201
    end

    post '/story/:id' do
      Story.find(params[:id]).update_attributes(params[:story])
    end

    put '/users' do
      status 201 if User.create!(params[:user])
    end

    post '/stories/:id/vote' do
      protected!
      story = Story.find(params[:id])
      vote = Vote.where(story: story, user: @user).first
      if vote
        vote.update_attribute("value", 1)
      else
        Vote.create!(user: @user, story: story, value: 1)
      end
      status 201
    end

    post '/stories/:id/downvote' do
      protected!
      story = Story.find(params[:id])
      vote = Vote.where(story: story, user: @user).first
      if vote
        vote.update_attribute("value", -1)
      else
        Vote.create!(user: @user, story: story, value: -1)
      end
      status 201
    end

    delete '/votes/:vote_id' do
      protected!
      vote = Vote.find(params[:vote_id])
      if vote.user.id == @user.id
        vote.destroy!
        status 200
      else 
        status 401
      end
    end
  end
end