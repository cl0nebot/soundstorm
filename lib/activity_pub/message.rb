# frozen_string_literal: true

module ActivityPub
  # Represents a message object on the +ActivityPub+ protocol, used for
  # encapsulating activity updates for transmission to other peers.
  class Message
    attr_reader :id, :type, :published, :actor, :payload

    delegate :id, :private_key, to: :actor, prefix: true

    def initialize(id:, type:, published: nil, actor:, payload:)
      @id = id
      @type = type
      @published = published || Time.current
      @actor = actor
      @payload = payload
    end

    def date
      published.utc.httpdate
    end

    def as_json
      {
        "@context": ACTIVITYSTREAMS_NAMESPACE,
        id: id,
        type: type,
        actor: actor.id,
        object: attributes
      }
    end

    def attributes
      payload.merge(to: "#{ACTIVITYSTREAMS_NAMESPACE}#Public")
    end
  end
end
