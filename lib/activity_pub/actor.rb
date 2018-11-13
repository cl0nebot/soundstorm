module ActivityPub
  # Represents the entity that creates activity messages.
  class Actor
    DEFAULT_TYPE = 'Person'

    attr_reader :name, :type, :host, :private_key

    delegate :public_key, to: :private_key
    delegate :to_json, to: :as_json

    def initialize(name:, type: DEFAULT_TYPE, host:, key:, secret:)
      @name = name
      @type = type
      @host = host
      @private_key = OpenSSL::PKey::RSA.new(key, secret)
    end

    def id
      "https://#{host}/#{name}"
    end

    def as_json
      {
        '@context': [ACTIVITYSTREAMS_NAMESPACE, W3ID_NAMESPACE],
        id: id,
        type: type,
        preferredUsername: name,
        inbox: inbox_url,
        publicKey: {
          id: "#{id}#main-key",
          owner: id,
          publicKeyPem: public_key.to_pem
        }
      }
    end

    def inbox_url
      "https://#{host}/inbox"
    end
  end
end