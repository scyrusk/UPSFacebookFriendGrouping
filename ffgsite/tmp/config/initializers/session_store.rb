# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ffgsite_session',
  :secret      => 'cd5245c04eb1187fd9d45fd7c3d6fc317cc1a53bde92536a1a5e5da4fafcd3d5e36b16f1d63252d23473686348cb9ebea8632b9a95dbab8a884ed989877e0af0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
