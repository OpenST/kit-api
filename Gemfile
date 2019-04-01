source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2.1'
gem 'mysql2', '0.5.2'
gem 'oj', '3.3.8'
gem 'rake', '12.3.1'

gem 'dalli', '2.7.9'

gem 'sanitize', '5.0.0'
gem 'exception_notification', '4.3.0'

gem 'aws-sdk-kms', '1.13.0'
gem 'aws-sdk-s3', '1.36.0'

gem 'http', '4.0.0'

gem 'rotp', '3.3.0' # required for MFA
gem 'jwt', '2.1.0'

gem 'sidekiq', '5.0.5'
gem 'redis-namespace', '1.6.0'

# required by rails dependencies
gem 'listen', '3.1.5'

# gem 'ost-sdk-ruby', '1.1.0'

group :development, :test do
  # Use Puma as the app server
  gem 'puma', '~> 3.7'

  gem 'pry'

  gem 'letter_opener'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # gem 'listen', '>= 3.0.5', '< 3.2'
  # # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
