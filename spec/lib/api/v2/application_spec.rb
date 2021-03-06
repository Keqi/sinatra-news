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

  describe "Accept-Language header" do
    it "returns response in default language if Accept-Language header wasnt passed" do
      put '/v2/users'

      expect(last_response.body).to include("Password must have at least 6 characters")
    end

    it "returns response in mostly accepted language" do
      put '/v2/users', {}, { "HTTP_ACCEPT_LANGUAGE" => "en;q=0.5, pl;q=0.8" }

      expect(last_response.body).to include("Password musi posiadać conajmniej 6 znaków")
    end

    it "returns 406 if none language is accepted" do
      put '/v2/users', {}, { "HTTP_ACCEPT_LANGUAGE" => "da;q=0.5, gb;q=0.8" }

      expect(last_response.status).to eq(406)
    end
  end

  describe "pagination helper" do
    before { 5.times { Story.create!(title: "title", url: "url") } }

    it "returns first and last page in 'Link' header if page param is not provided" do
      get '/v2/stories'

      expect(last_response.header["Link"].include?("<http://example.org/v2/stories?page=1>; rel='first'")).to eq(true)
      expect(last_response.header["Link"].include?("<http://example.org/v2/stories?page=3>; rel='last'")).to eq(true)
    end

    it "returns next page in 'Link' header if page param is provided and it isnt last page" do
      get '/v2/stories?page=2'
      expect(last_response.header["Link"].include?("<http://example.org/v2/stories?page=3>; rel='next'")).to eq(true)
    end

    it "returns previous page in 'Link' header if page params is provided and it isnt first page" do
      get '/v2/stories?page=2'
      expect(last_response.header["Link"].include?("<http://example.org/v2/stories?page=1>; rel='prev'")).to eq(true)
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