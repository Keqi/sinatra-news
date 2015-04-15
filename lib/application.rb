require 'sinatra'
require 'json'

module PilotNews
  class Application < Sinatra::Base
    get '/stories' do
      [
        { title: "Example 1", url: "http://lipsum.com" },
        { title: "Example 2", url: "http://lipsum.uk" }
      ].to_json
    end

    get '/stories/:id' do
      { title: "Example 1", url: "http://lipsum.com" }.to_json
    end
  end
end