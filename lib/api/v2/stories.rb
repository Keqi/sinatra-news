require_relative '../../helpers/pagination_helper'
module PilotNews
  module API
    module V2
      class Stories < Base
        include PaginationHelper
        namespace '/v2' do
          namespace '/stories' do
            get '' do
              if modified_since?
                headers \
                  "Link" => link_header
                respond_with(Story.popular.page(params[:page] || 1))
              else
                status(304)
              end
            end

            get '/recent' do
              cache_control max_age: 20, public: true
              headers \
                  "Link" => link_header
              respond_with Story.order("created_at DESC").page(params[:page] || 1)
            end

            put '' do
              protected!
              story = Story.new(params[:story])
              story.user = user
              story.save!
              status 201
            end

            get '/:id' do
              respond_with story
            end

            get '/:id/url' do
              redirect Story.find(params[:id]).url, 303
            end

            post '/:id' do
              protected!
              story.user == user ? story.update_attributes(params[:story]) : halt(401, "Not authorized\n")
            end

            post '/:id/vote' do
              protected!
              vote ? vote.update_attribute("value", 1) : Vote.create!(user: user, story: story, value: 1)
              Board.first.touch
              status 201
            end

            post '/:id/downvote' do
              protected!
              vote ? vote.update_attribute("value", -1) : Vote.create!(user: user, story: story, value: -1)
              Board.first.touch
              status 201
            end

            delete '/:id' do
              protected!
              if story.user == user
                story.destroy
                status 201
              else
                halt(401, "Not authorized\n")
              end
            end
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

        def modified_since?
          return true unless request.env["HTTP_HTTP_IF_MODIFIED_SINCE"]

          date = DateTime.parse(request.env["HTTP_HTTP_IF_MODIFIED_SINCE"])
          Board.first.updated_at < date
        end
      end
    end
  end
end