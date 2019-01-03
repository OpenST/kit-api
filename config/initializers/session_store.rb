# Be sure to restart your server when you modify this file.
Rails.application.config.middleware.use ActionDispatch::Cookies
# key _ost_platform_session_id should be same as in company web in order to make CSRF work
Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, key: '_ost_kit_session_id', domain: :all, http_only: true, secure: Rails.env.production?, same_site: :strict

