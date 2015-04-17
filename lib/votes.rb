module PilotNews
  class Votes < Base
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

    private

    def vote
      @vote ||= Vote.where(story: story, user: user).first
    end
  end
end