# frozen_string_literal: true

module TracksHelper
  def track_player_button(audio)
    return unless audio.attached?

    bindings = { target: 'player.button', action: 'click->player#toggle' }

    link_to '&nbsp'.html_safe, url_for(audio), data: bindings, title: t('.play'), class: %w(player__icon player__icon--paused)
  end

  def player_for(track, &block)
    data = {
      controller: 'player',
      track: url_for([track.user, track]),
      liked: current_user.likes?(track),
      duration: track.duration
    }

    content_tag :section, class: 'player', data: data, &block
  end

  def like_button_for(track, &block)
    if track.user == current_user
      player_link(&block)
    else
      like_button(track, &block)
    end
  end

  def track_comments_url(track)
    user_track_url(track.user, track, anchor: 'comments')
  end

  private

  def player_link(&block)
    content_tag :span, class: 'player__link' do
      yield
    end
  end

  def like_button(track)
    options = {
      method: :post,
      class: 'player__link',
      data: {
        action: 'ajax:success->player#like',
        target: 'like'
      }
    }

    button_to [track.user, track, :like], options do
      yield
    end
  end
end
