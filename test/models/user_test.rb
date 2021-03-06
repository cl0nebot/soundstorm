# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'compute handle from configured host' do
    name = 'test'
    domain = Rails.configuration.host
    user = User.new(name: name)

    assert_equal "#{name}@#{domain}", user.handle
  end

  test 'generate private key for new user' do
    user = User.create(
      name: 'new-user',
      host: Rails.configuration.host,
      display_name: 'New User',
      password: 'HelloD0lly1!',
      email: 'new-user@example.com'
    )

    assert user.valid?, user.errors.full_messages.to_sentence
    assert user.key_pem.present?
  end

  test 'regenerate private key when password changes' do
    user = users(:one)

    assert_changes -> { user.key_pem } do
      assert user.update!(password: 'TotallyN3wPassword$')
    end
  end
end
