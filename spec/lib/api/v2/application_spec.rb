require 'spec_helper'
require 'pry'

RSpec.describe PilotNews::Application do
  let(:app) { Rack::Lint.new(PilotNews::Application) }

  let!(:board) { Board.create!(title: 'Famous sites', updated_at: 1.week.ago) }
  let!(:user)  { User.create!(username: 'maciorn', password: 'secret') }
  let!(:story) { Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com', user: user, board: board) }

  describe "GET /stories" do
    it "returns 200 with new body when 'if-modified-since' header is valid" do
      get '/v2/stories', {}, {"HTTP_HTTP_IF_MODIFIED_SINCE" => 3.days.ago.to_s }

      expect(last_response.status).to eq(200)
      expect(last_response.body).not_to be_empty
    end

    it "returns 304 with empty body when 'if-modified-since' header is invalid" do
      get '/v2/stories', {}, {"HTTP_HTTP_IF_MODIFIED_SINCE" => 10.days.ago.to_s }

      expect(last_response.status).to eq(304)
      expect(last_response.body).to be_empty
    end
  end

  describe "GET /stories/recent" do
    it "returns last 5 recent stories" do
      6.times { Story.create! }
      get '/v2/stories/recent'

      expect(JSON.parse(last_response.body).to_json).to eq(Story.order("created_at DESC").last(5).to_json)
    end
  end

  describe "DELETE /stories/:id" do
    it "deletes story from db" do
      authorize user.username, user.password
      delete "/v2/stories/#{story.id}"

      expect(last_response.status).to eq(201)
      expect(Story.count).to eq(0)
      expect(user.stories.count).to eq(0)
    end

    it "can not delete story if user wasnt authorized" do
      authorize user.username, "pass"
      delete "/v2/stories/#{story.id}"

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Not authorized\n")
      expect(Story.count).to eq(1)
    end

    it "API version 1 doesnt include this endpoint" do
      authorize user.username, user.password
      delete "/v1/stories/#{story.id}"

      expect(last_response.status).to eq(404)
      expect(Story.count).to eq(1)
    end
  end
end