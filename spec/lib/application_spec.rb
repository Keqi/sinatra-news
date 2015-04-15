require 'spec_helper'
require 'pry'

RSpec.describe PilotNews::Application do
  let(:app) { Rack::Lint.new(PilotNews::Application) }

  describe "API" do
    let!(:story) { Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com') }

    describe "GET /stories" do
      it "returns list of all submitted stories" do
        # Story.create!(title: 'ipsum lorem', url: 'http://www.lipsum.uk')

        get '/stories'
        body = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(body.count).to eq(2)
      end
    end

    describe "GET /stories/:id" do
      it "returns single story by given id" do
        get "/stories/1"
        parsed_response = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(parsed_response["title"]).to eq('Example 1')
        expect(parsed_response["url"]).to eq("http://lipsum.com")
      end

      it "returns 404 if story wasn't found", pending: true do
        get "/story/987654321"

        expect(last_response.status).to eq(404)
      end
    end

    describe "PUT /story", pending: true do
      it "creates new story in database" do
        put "/story", { title: "New story", url: "http://example.com" }

        story = Story.last
        expect(Story.count).to eq(2)
        expect(story.title).to eq("New story")
        expect(story.url).to eq("http://example.com")

        expect(last_response.status).to eq(201)
      end
    end

    describe "POST /story/:id", pending: true do
      it "updates story in database" do
        post "/story/#{story.id}", { title: "New title" }

        expect(last_response.status).to eq(200)
        expect(story.reload.title).to eq("New title")
      end

      it "returns 404 if story not found" do
        post "/story/987654321", { title: "New title" }

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /story/:id/vote", pending: true do
      it "upvotes story" do
        post "/story/#{story.id}/vote"

        expect(last_response.status).to eq(200)
        expect(Vote.count).to eq(1)
      end

      it "returns 404 if story not found" do
        post "/story/987654321/vote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /story/:id/downvote", pending: true do
      it "downvotes story" do
        post "/story/#{story.id}/downvote"

        expect(last_response.status).to eq(200)
        expect(Vote.count).to eq(1)
      end

      it "returns 404 if story not found" do
        post "/story/987654321/downvote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "DELETE /story/:id/vote/:vote_id", pending: true do
      let!(:vote) { Vote.create!(story: story) }

      it "destroys vote object" do
        delete "/story/#{story.id}/vote/#{vote.id}"

        expect(last_response.status).to eq(200)
        expect(Vote.count).to eq(0)
      end

      it "returns 404 if story not found" do
        delete "/story/987654321/vote/#{vote.id}"

        expect(last_response.status).to eq(404)
      end

      it "returns 404 if vote not found" do
        delete "/story/#{story.id}/vote/987654321"

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /users", pending: true do
      it "creates new user" do
        post '/users', { username: 'maciorn', password: 'secret' }

        expect(last_response.status).to eq(201)
        expect(User.count).to eq(1)
      end
    end
  end
end