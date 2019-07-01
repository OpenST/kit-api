#Note this secret has to be same for kit-web & kit-api in order to make CSRF work
export COMPANY_SECRET_KEY_BASE='fc06a409bf0a2fc2e8b316ceeb04e8675900f3176668d2a836494417e0164a966aefd701430390d3db685f87c224cbb48b332f8a5cf490fa7f034e063ff13a94'

# Support email
export KA_SUPPORT_EMAIL='support@ost.com'

# Database details
export KA_KIT_SUBENV_MYSQL_HOST=127.0.0.1
export KA_KIT_SUBENV_MYSQL_USER=root
export KA_KIT_SUBENV_MYSQL_PASSWORD=root

export KA_KIT_CLIENT_MYSQL_HOST=127.0.0.1
export KA_KIT_CLIENT_MYSQL_USER=root
export KA_KIT_CLIENT_MYSQL_PASSWORD=root

export KA_KIT_SAAS_SUBENV_MYSQL_HOST=127.0.0.1
export KA_KIT_SAAS_SUBENV_MYSQL_USER=root
export KA_KIT_SAAS_SUBENV_MYSQL_PASSWORD=root

export KA_KIT_SAAS_MYSQL_HOST=127.0.0.1
export KA_KIT_SAAS_MYSQL_USER=root
export KA_KIT_SAAS_MYSQL_PASSWORD=root

export KA_SAAS_SUBENV_MYSQL_HOST=127.0.0.1
export KA_SAAS_SUBENV_MYSQL_USER=root
export KA_SAAS_SUBENV_MYSQL_PASSWORD=root

export KA_SAAS_BIG_SUBENV_MYSQL_HOST=127.0.0.1
export KA_SAAS_BIG_SUBENV_MYSQL_USER=root
export KA_SAAS_BIG_SUBENV_MYSQL_PASSWORD=root

export KA_KIT_BIG_SUBENV_MYSQL_HOST=127.0.0.1
export KA_KIT_BIG_SUBENV_MYSQL_USER=root
export KA_KIT_BIG_SUBENV_MYSQL_PASSWORD=root

export KA_KIT_SAAS_BIG_SUBENV_MYSQL_HOST=127.0.0.1
export KA_KIT_SAAS_BIG_SUBENV_MYSQL_USER=root
export KA_KIT_SAAS_BIG_SUBENV_MYSQL_PASSWORD=root

export KA_CONFIG_SUBENV_MYSQL_HOST=127.0.0.1
export KA_CONFIG_SUBENV_MYSQL_USER=root
export KA_CONFIG_SUBENV_MYSQL_PASSWORD=root

# Core ENV Details
export KA_SUB_ENV='sandbox'
export ENV_IDENTIFIER='internal'
export KA_COOKIE_DOMAIN='kit.developmentost.com'

# Admin basic auth
export KA_ADMIN_BASIC_AUTH_USERNAME='ostAdmin'
export KA_ADMIN_BASIC_AUTH_PASSWORD='dAss$14nflkn!'

# Redis Details
export KA_REDIS_ENDPOINT='redis://ca:st123@127.0.0.1:6379'

# AWS Defaults
export KA_DEFAULT_AWS_REGION="us-east-1"
export KA_S3_MASTER_FOLDER="d-sandbox"

# S3 Details
export KA_S3_DOMAIN="https://s3.amazonaws.com"

# Private S3 Details
export KA_S3_ACCESS_KEY="AKIAIG7G5KJ53INDY36A"
export KA_S3_SECRET_KEY="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"
export KA_S3_REPORTS_BUCKET="reports.stagingost.com"
export KA_S3_REPORTS_PLATFORM_USAGE_FOLDER="platform-usage"
export KA_S3_ANALYTICS_BUCKET="graphs.stagingost.com"
export KA_S3_ANALYTICS_GRAPHS_FOLDER="graphs"

# Public S3 Details
export KA_S3_PUBLIC_ACCESS_KEY="AKIA2IE3EXDCMPSHH3ZA"
export KA_S3_PUBLIC_SECRET_KEY="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"
export KA_S3_PUBLIC_BUCKET="public.stagingost.com"
export KA_S3_PUBLIC_TEST_ECONOMY_QR_CODE_FOLDER="test-economy/qr-code"

# KMS Details
export KA_USER_AWS_ACCESS_KEY="AKIAJUDRALNURKAVS5IQ"
export KA_USER_AWS_SECRET_KEY="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"
export KA_LOGIN_KMS_ARN='arn:aws:kms:us-east-1:604850698061:key'
export KA_LOGIN_KMS_ID='eab8148d-fd9f-451d-9eb9-16c115645635'
export KA_API_KEY_KMS_ARN='arn:aws:kms:us-east-1:604850698061:key'
export KA_API_KEY_KMS_ID='eab8148d-fd9f-451d-9eb9-16c115645635'

# Secret Encryptor Details
export KA_COOKIE_SECRET_KEY='byfd#ss@#4nflkn%^!~wkk^^&71o{23dpi~@jwe$pi'
export KA_EMAIL_TOKENS_DECRIPTOR_KEY='3d3w6fs0983ab6b1e37d1c1fs64hm8g9'
export KA_GENERIC_SHA_KEY='9fa6baa9f1ab7a805b80721b65d34964170b1494'
export KA_CACHE_DATA_SHA_KEY='805a65cbc02c97a567481414a7cb8bf4'

# Key which is used to encrypt url id which is used for Token Demo
export KA_TOKEN_DEMO_SHA_KEY='814a56744a7cb8bf4805a651cbc02c97'

# Auth token to allow activation of test economy even in Main Sub Env
export KA_ACTIVATE_TEST_ECONOMY_AUTH_TOKEN='814a56744a7cb8bf4805a651cbc02c97'

# Captcha Details
export KA_RECAPTCHA_SITE_KEY='6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
export KA_RECAPTCHA_SECRET='6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'

# Memcached Details
export KA_MEMCACHED_INSTANCES='127.0.0.1:11211'

# Pepo Campaigns Details
export KA_CAMPAIGN_CLIENT_KEY="f395013cc8715f72ecef978248d933e6"
export KA_CAMPAIGN_CLIENT_SECRET="818506e0d00c33f84099744461b41ac5"
export KA_CAMPAIGN_BASE_URL="https://pepocampaigns.com/"
export KA_CAMPAIGN_MASTER_LIST="5346"

# Company Restful API (SAAS) details
export KA_SAAS_API_ENDPOINT='http://developmentost.com:7001'
export KA_SAAS_API_SECRET_KEY='1somethingsarebetterkeptinenvironemntvariables'

# Company Web Details
export KA_CW_DOMAIN='developmentost.com'

# Company Other Product URL
export KA_VIEW_ROOT_URL='http://view.developmentost.com:8080'
export KA_OST_WEB_ROOT_URL='http://developmentost.com:8080'

# Demo Mappy Server Details
export KA_DEMO_MAPPY_SERVER_API_ENDPOINT='http://127.0.0.1:3000/demo'
export KA_DEMO_MAPPY_SERVER_SECRET_KEY='1somethingsarebetterkeptinenvironemntvariables'

# Demo App URL's
export KA_DEMO_IOS_APP_URL='https://s3.amazonaws.com/sdk.stagingost.com/iOS/Download.html'
export KA_DEMO_ANDROID_APP_URL='http://sdk.stagingost.com.s3.amazonaws.com/Android/release/demoapp-release.apk'

# Usage report recipient's email ids
export KA_USAGE_REPORT_RECIPIENTS_EMAIL_IDS="[\"backend@ost.com\"]"

# Jira Details
export KA_JIRA_USERNAME=''
export KA_JIRA_PASSWORD=''
export KA_JIRA_PROJECT_NAME='TP'
export KA_JIRA_AUTH_TYPE=':basic'
export KA_JIRA_ASSIGNEE_NAME=''

# Pipedrive Details
export KA_OST_PD_API_TOKEN="0c5740a0fa913e7e06683d12934fc8e71e3706ba"
export KA_OST_ENTERPRISE_PD_USER_ID="8857041"
export KA_OST_BUSINESS_PD_USER_ID="8966142"
export KA_OST_ENTERPRISE_PD_STAGE_ID="7"
export KA_OST_BUSINESS_PD_STAGE_ID="8"
export KA_PD_DEAL_ENTERPRISE_CUSTOM_FIELD='4c4a5c203f18967271754c0cf8d0ad79f8ca2c32'
export KA_PD_DEAL_MOBILE_APP_CUSTOM_FIELD='7b052508c4d2918872c156ae8c8f124c210ab4f3'

# Popcorn economy
export OST_POPCORN_ECONOMY=1129