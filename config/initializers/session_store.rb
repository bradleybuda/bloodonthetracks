# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bloodonthetracks_session',
  :secret      => 'd22a08f920b5f7406f1e336a986db629bc218b28bb8e986804616dfb4ce31d208520608fcfaf40c564384cad1d01f4c764d998dc018bb9181066b0d70d7b6f9d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
