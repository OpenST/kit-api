#Note this secret has to be same for kit-web & kit-api in order to make CSRF work
export COMPANY_SECRET_KEY_BASE='fc06a409bf0a2fc2e8b316ceeb04e8675900f3176668d2a836494417e0164a966aefd701430390d3db685f87c224cbb48b332f8a5cf490fa7f034e063ff13a94'

# Database details
export KA_DEFAULT_DB_HOST=127.0.0.1
export KA_DEFAULT_DB_USER=root
export KA_DEFAULT_DB_PASSWORD=

export KA_SUB_ENV_SHARED_DB_HOST=127.0.0.1
export KA_SUB_ENV_SHARED_DB_USER=root
export KA_SUB_ENV_SHARED_DB_PASSWORD=

export KA_SAAS_DEFAULT_DB_HOST=127.0.0.1
export KA_SAAS_DEFAULT_DB_USER=root
export KA_SAAS_DEFAULT_DB_PASSWORD=

export KA_SAAS_SHARED_DB_HOST=127.0.0.1
export KA_SAAS_SHARED_DB_USER=root
export KA_SAAS_SHARED_DB_PASSWORD=

# Core ENV Details
export KA_SUB_ENV='sandbox'
export ENV_IDENTIFIER='internal'

# Admin basic auth
export KA_ADMIN_BASIC_AUTH_USERNAME='ostAdmin'
export KA_ADMIN_BASIC_AUTH_PASSWORD='dAss$14nflkn!'

# Redis Details
export KA_REDIS_ENDPOINT='redis://ca:st123@127.0.0.1:6379'

# AWS Details
export KA_DEFAULT_AWS_REGION="us-east-1"
export KA_USER_AWS_ACCESS_KEY="AKIAJUDRALNURKAVS5IQ"
export KA_USER_AWS_SECRET_KEY="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"

# KMS Details
export KA_LOGIN_KMS_ARN='arn:aws:kms:us-east-1:604850698061:key'
export KA_LOGIN_KMS_ID='eab8148d-fd9f-451d-9eb9-16c115645635'
export KA_API_KEY_KMS_ARN='arn:aws:kms:us-east-1:604850698061:key'
export KA_API_KEY_KMS_ID='eab8148d-fd9f-451d-9eb9-16c115645635'

# Secret Encryptor Details
export KA_COOKIE_SECRET_KEY='byfd#ss@#4nflkn%^!~wkk^^&71o{23dpi~@jwe$pi'
export KA_EMAIL_TOKENS_DECRIPTOR_KEY='3d3w6fs0983ab6b1e37d1c1fs64hm8g9'
export KA_GENERIC_SHA_KEY='9fa6baa9f1ab7a805b80721b65d34964170b1494'
export KA_KACHE_DATA_SHA_KEY='805a65cbc02c97a567481414a7cb8bf4'

# Captcha Details
export KA_REKAPTCHA_SITE_KEY='6Lc64n8UAAAAAFTaC0Gvi5K7-pLjPh_LLShsSgta'
export KA_REKAPTCHA_SECRET='6Lc64n8UAAAAAEUAhaB4y6lbKdZDZxPeWiKAkPGg'

# Memcached Details
export KA_MEMKACHED_INSTANCES='127.0.0.1:11211'

# Pepo Campaigns Details
export KA_KAMPAIGN_CLIENT_KEY="f395013cc8715f72ecef978248d933e6"
export KA_KAMPAIGN_CLIENT_SECRET="818506e0d00c33f84099744461b41ac5"
export KA_KAMPAIGN_BASE_URL="https://pepocampaigns.com/"
export KA_KAMPAIGN_MASTER_LIST="3722"

# Company Restful API (SAAS) details
export KA_SAAS_API_ENDPOINT='http://developmentost.com:7001'
export KA_SAAS_API_SECRET_KEY='1somethingsarebetterkeptinenvironemntvariables'

# Company Web Details
export KA_CW_DOMAIN='developmentost.com'

# OST Explorer Apis
export KA_EXPLORER_BASE_URL='http://view.developmentost.com:7000/'
export KA_EXPLORER_SECRET_KEY='6p5BkI0uGHI1JPrAKP3eB1Zm88KZ84a9Th9o4syhwZhxlv0oe0'
