# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :secret, :unsigned_session_cookie,
                                               :secret_key_base, :cookie_hash, :cookie_string]