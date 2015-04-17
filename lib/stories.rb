module PilotNews
  class Stories < Base

    namespace '/stories' do
      get '' do
        Story.all.to_json
      end

      put '' do
        protected!
        story = Story.new(params[:story])
        story.user = user
        story.save!
        status 201
      end

      get '/:id' do
        story.to_json
      end

      post '/:id' do
        protected!
        story.user == user ? story.update_attributes(params[:story]) : halt(401, "Not authorized\n")
      end

      post '/:id/vote' do
        protected!
        vote ? vote.update_attribute("value", 1) : Vote.create!(user: user, story: story, value: 1)
        status 201
      end

      post '/:id/downvote' do
        protected!
        vote ? vote.update_attribute("value", -1) : Vote.create!(user: user, story: story, value: -1)
        status 201
      end
    end

    private

    def story
      @story ||= Story.find(params[:id])
    end

    def vote
      @vote ||= Vote.where(story: story, user: user).first
    end

    def user
      @user ||= User.where(username: @auth.credentials.first, password: @auth.credentials.last).first
    end
  end
end