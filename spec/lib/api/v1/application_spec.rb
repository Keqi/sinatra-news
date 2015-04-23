require 'spec_helper'
require 'pry'

RSpec.describe PilotNews::Application do
  let(:app) { Rack::Lint.new(PilotNews::Application) }

  describe "API" do
    let!(:user)  { User.create!(username: 'maciorn', password: 'secret') }
    let!(:story) { Story.create!(title: 'Lorem ipsum', url: 'http://www.lipsum.com', user: user) }

    describe "versioning" do
      it "throws 501 if version is not supported" do
        get "/v3/stories/#{story.id}"

        expect(last_response.status).to eq(501)
        expect(last_response.body).to eq("Version not supported")
      end
    end

    describe "GET /v1/stories" do
      it "returns list of all submitted stories" do
        Story.create!(title: 'ipsum lorem', url: 'http://www.lipsum.uk')

        get '/v1/stories'
        body = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(body.count).to eq(2)
      end
    end

    describe "GET /v1/stories/:id" do
      it "returns single story by given id" do
        get "/v1/stories/#{story.id}"
        parsed_response = JSON.parse(last_response.body)

        expect(last_response.ok?).to eq(true)
        expect(parsed_response["title"]).to eq('Lorem ipsum')
        expect(parsed_response["url"]).to eq("http://www.lipsum.com")
      end

      it "returns 404 if story wasn't found" do
        get "/v1/stories/987654321"

        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq("Couldn't find Story with 'id'=987654321")
      end
    end

    describe "PUT /stories" do
      it "creates new story in database" do
        authorize user.username, user.password
        put "/v1/stories", { story: { title: "New story", url: "http://example.com" } }

        story = Story.last
        expect(Story.count).to eq(2)
        expect(story.title).to eq("New story")
        expect(story.url).to eq("http://example.com")

        expect(story.user.username).to eq('maciorn')
        expect(story.user.password).to eq('secret')

        expect(last_response.status).to eq(201)
      end

      it "returns 422 if validation fails" do
        authorize user.username, user.password
        put "/v1/stories", { story: { } }

        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Validation failed: Title can't be blank, Url can't be blank")
      end

      it "returns 401 with unathorized HEADER if user not found" do
        User.create!(username: 'maciorn', password: 'secret')
        authorize 'maciorn', 'secret1'
        put "/v1/stories", { story: { title: "New story", url: "http://example.com" } }

        expect(last_response.status).to eq(401)
        expect(last_response.headers["WWW-Authenticate"]).to eq("Restricted Area")
        expect(Story.count).to eq(1)
      end
    end

    describe "POST /stories/:id"  do
      it "updates story in database" do
        authorize user.username, user.password
        post "/v1/stories/#{story.id}", { story: { title: "New title" } }

        expect(last_response.status).to eq(200)
        expect(story.reload.title).to eq("New title")
      end

      it "returns 401 Unauthorized if story doesnt belong to authorized user" do
        another_user = User.create!(username: 'newmaciorn', password: 'secret')
        authorize another_user.username, another_user.password

        post "/v1/stories/#{story.id}", { story: { title: "New title" } }

        expect(last_response.status).to eq(401)
      end

      it "returns 422 if validation fails" do
        authorize user.username, user.password
        post "/v1/stories/#{story.id}", { story: { title: nil, url: nil } }

        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Validation failed: Title can't be blank, Url can't be blank")
      end

      it "returns 404 if story not found" do
        authorize user.username, user.password
        post "/v1/stories/987654321", { story: { title: "New title" } }

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /stories/:id/vote"  do
      it "upvotes story" do
        authorize user.username, user.password

        post "/v1/stories/#{story.id}/vote"
        vote = Vote.last

        expect(last_response.status).to eq(201)
        expect(vote.user).to eq(user)
        expect(vote.story).to eq(story)
        expect(vote.value).to eq(1)
      end

      it "doesnt let user to upvote same story twice" do
        Vote.create!(user: user, story: story)

        authorize user.username, user.password

        post "/v1/stories/#{story.id}/vote"

        expect(Vote.count).to eq(1)
        expect(last_response.status).to eq(201)
      end

      it "returns 404 if story not found" do
        authorize user.username, user.password
        post "/v1/stories/987654321/vote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "POST /stories/:id/downvote"  do
      it "downvotes story" do
        authorize user.username, user.password

        post "/v1/stories/#{story.id}/downvote"
        vote = Vote.last

        expect(last_response.status).to eq(201)
        expect(vote.user).to eq(user)
        expect(vote.story).to eq(story)
        expect(vote.value).to eq(-1)
      end

      it "doesnt let user to upvote same story twice" do
        Vote.create!(user: user, story: story)

        authorize user.username, user.password

        post "/v1/stories/#{story.id}/downvote"

        expect(Vote.count).to eq(1)
        expect(last_response.status).to eq(201)
      end

      it "returns 404 if story not found" do
        authorize user.username, user.password
        post "/v1/stories/987654321/downvote"

        expect(last_response.status).to eq(404)
      end
    end

    describe "DELETE votes/:vote_id"  do
      let!(:vote) { Vote.create!(user: user, story: story) }

      it "destroys vote object" do
        authorize user.username, user.password
        delete "/v1/votes/#{vote.id}"

        expect(last_response.status).to eq(200)
        expect(Vote.count).to eq(0)
      end

      it "returns 404 if vote not found" do
        authorize user.username, user.password
        delete "/v1/votes/987654321"

        expect(last_response.status).to eq(404)
      end

      it "returns 401 if user wasn't authorized" do
        authorize "fake_user", user.password
        delete "/v1/votes/#{vote.id}"

        expect(last_response.status).to eq(401)
      end
    end

    describe "PUT /users"  do
      it "creates new user" do
        put '/v1/users', { user: { username: 'maciorn', password: 'secret' } }

        expect(last_response.status).to eq(201)
        expect(User.count).to eq(2)
      end

      it "returns 422 if user couldn't be created" do
        put '/v1/users', { user: { password: 'secret' } }

        expect(last_response.status).to eq(422)
        expect(last_response.body).to eq("Validation failed: Username can't be blank")
      end
    end
  end
end