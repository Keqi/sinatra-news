require 'spec_helper'
require 'pry'

RSpec.describe PilotNews::Application do
  let(:app) { Rack::Lint.new(PilotNews::Application) }

  describe "API" do
    let!(:user)  { User.create!(username: 'maciorn', password: 'secret') }
    let!(:story) { Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com', user: user) }

    describe "GET /stories" do
      it "returns list of all submitted stories" do
        Story.create!(title: 'ipsum lorem', url: 'http://www.lipsum.uk')

        get '/stories'
        body = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(body.count).to eq(2)
      end
    end

    describe "GET /stories/:id" do
      it "returns single story by given id" do
        get "/stories/#{story.id}"
        parsed_response = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(parsed_response["title"]).to eq('Lorem ipsum')
        expect(parsed_response["url"]).to eq("http://www.lipsum.com")
      end

      it "returns 404 if story wasn't found" do
        get "/story/987654321"

        expect(last_response.status).to eq(404)
      end
    end

    describe "PUT /story" do
      it "creates new story in database" do
        authorize user.username, user.password
        put "/story", { story: { title: "New story", url: "http://example.com" } }

        story = Story.last
        expect(Story.count).to eq(2)
        expect(story.title).to eq("New story")
        expect(story.url).to eq("http://example.com")

        expect(story.user.username).to eq('maciorn')
        expect(story.user.password).to eq('secret')

        expect(last_response.status).to eq(201)
      end

      it "returns 401 with unathorized HEADER if user not found" do
        User.create!(username: 'maciorn', password: 'secret')
        authorize 'maciorn', 'secret1'
        put "/story", { story: { title: "New story", url: "http://example.com" } }

        expect(last_response.status).to eq(401)
        expect(last_response.headers["WWW-Authenticate"]).to eq("Restricted Area")
        expect(Story.count).to eq(1)
      end
    end

    describe "POST /story/:id"  do
      it "updates story in database" do
        post "/story/#{story.id}", { story: { title: "New title" } }

        expect(last_response.status).to eq(200)
        expect(story.reload.title).to eq("New title")
      end

      it "returns 404 if story not found" do
        post "/story/987654321", { title: "New title" }

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /stories/:id/vote"  do
      it "upvotes story" do
        authorize user.username, user.password

        post "/stories/#{story.id}/vote"
        vote = Vote.last

        expect(last_response.status).to eq(201)
        expect(vote.user).to eq(user)
        expect(vote.story).to eq(story)
        expect(vote.value).to eq(1)
      end

      it "doesnt let user to upvote same story twice" do
        Vote.create!(user: user, story: story)

        authorize user.username, user.password

        post "/stories/#{story.id}/vote"

        expect(Vote.count).to eq(1)
        expect(last_response.status).to eq(201)
      end

      it "returns 404 if story not found" do
        post "/story/987654321/vote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /story/:id/downvote"  do
      it "downvotes story" do
        authorize user.username, user.password

        post "/stories/#{story.id}/downvote"
        vote = Vote.last

        expect(last_response.status).to eq(201)
        expect(vote.user).to eq(user)
        expect(vote.story).to eq(story)
        expect(vote.value).to eq(-1)
      end

      it "doesnt let user to upvote same story twice" do
        Vote.create!(user: user, story: story)

        authorize user.username, user.password

        post "/stories/#{story.id}/downvote"

        expect(Vote.count).to eq(1)
        expect(last_response.status).to eq(201)
      end

      it "returns 404 if story not found" do
        post "/story/987654321/downvote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "DELETE votes/:vote_id"  do
      let!(:vote) { Vote.create!(user: user, story: story) }

      it "destroys vote object" do
        authorize user.username, user.password
        delete "/votes/#{vote.id}"

        expect(last_response.status).to eq(200)
        expect(Vote.count).to eq(0)
      end

      it "returns 404 if vote not found" do
        authorize user.username, user.password
        delete "/votes/987654321"

        expect(last_response.status).to eq(404)
      end

      it "returns 401 if user wasn't authorized" do
        authorize "fake_user", user.password
        delete "/votes/#{vote.id}"

        expect(last_response.status).to eq(401)
      end
    end

    describe "PUT /users"  do
      it "creates new user" do
        put '/users', { username: 'maciorn', password: 'secret' }

        expect(last_response.status).to eq(201)
        expect(User.count).to eq(1)
      end
    end
  end
end