# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_solaris-rebuild_session',
  :secret      => '3a77cb5634348d7c1454f891236e52fc7a15db263bba55d05533a9f29b99bd611c00ad34a01d68ffb37c70c4184ca4bdacfc1b49eb1894d22290f27ad0232f92'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
