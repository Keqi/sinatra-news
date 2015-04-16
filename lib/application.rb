require 'active_record'
require 'sinatra'
require 'json'
require 'dotenv'
require_relative 'models/story'

module PilotNews
  class Application < Sinatra::Base
    configure do
      Dotenv.load(".env.#{environment}", '.env')
      ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

      use ActiveRecord::ConnectionAdapters::ConnectionManagement
    end

    get '/stories' do
      Story.all.to_json
    end

    get '/stories/:id' do
      Story.find(params[:id]).to_json
    end

    put '/story' do
      Story.create!(params[:story])
      status 201
    end

    post '/story/:id' do
      Story.find(params[:id]).update_attributes(params[:story])
    end
  end
end