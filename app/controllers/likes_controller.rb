# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :cache_page, only: :index
  skip_before_action :authorize_admin!, only: :index

  def index
    @likes = current_user.likes
  end

  def create
    @track = Track.find(params[:track_id])

    respond_to do |format|
      if current_user.like!(@track)
        flash[:notice] = t('.success', track: @track.name)

        format.html { redirect_back fallback_location: [@track.user, @track] }
        format.json { render json: { likes: @track.likees_count } }
      else
        flash[:alert] = t('.failure', track: @track.name)

        format.html { redirect_back fallback_location: [@track.user, @track] }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @track = Track.find(params[:track_id])

    respond_to do |format|
      if current_user.unlike!(@track)
        flash[:notice] = t('.success', track: @track.name)

        format.html { redirect_back fallback_location: [@track.user, @track] }
        format.json { render json: { likes: @track.likees_count } }
      else
        flash[:alert] = t('.failure', track: @track.name)

        format.html { redirect_back fallback_location: [@track.user, @track] }
        format.json { head :unprocessable_entity }
      end
    end
  end
end
