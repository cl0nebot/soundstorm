# frozen_string_literal: true

class Comment < ApplicationRecord
  include Federatable
  include Searchable

  FIELDS = %w(author track content)

  belongs_to :user
  belongs_to :track, counter_cache: true
  belongs_to :parent, class_name: 'Comment', optional: true

  has_many :children, foreign_key: :parent_id, class_name: 'Comment'

  acts_as_mentioner

  before_validation :assign_parent_track, unless: :root?

  validates :content, presence: true

  scope :roots, -> { where(parent: nil) }

  after_create :notify_replied_user, if: :reply?
  after_save :mention_users

  delegate :name, to: :user, prefix: true

  attr_writer :author, :user_name

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :content
      indexes :author
      indexes :user_name
    end
  end

  def author
    user.display_name
  end

  def root?
    parent.blank?
  end

  def reply?
    !root?
  end

  def leaf?
    children.none?
  end

  def parent_activity_id
    root? ? track.activity_id : parent.activity_id
  end

  def activity_id
    Rails.application.routes.url_helpers.user_track_comment_url(
      track.user, track, self, host: track.user.host
    )
  end

  def as_activity
    super.merge(
      type: 'Note',
      inReplyTo: parent_activity_id,
      content: content
    )
  end

  def as_indexed_json(options = {})
    as_json.merge(author: author, user_name: user_name)
  end

  def mentioned_users
    mentionees(User)
  end

  private

  def assign_parent_track
    self.track = parent.track
  end

  def mention_users
    content.scan(Mention::SYNTAX) do |mention|
      username = mention.gsub(Mention::DEFIX, '')
      user = User.find_by(name: username)
      next unless user.present?
      mention!(user)
    end
  end

  def notify_replied_user
    NotificationMailer.reply(self, user).deliver_later
  end
end
