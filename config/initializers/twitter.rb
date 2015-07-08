#Load from YAML file in local machine
# TWITTER_CONFIG = YAML.load_file(Rails.root.join('config', 'twitter.yml'))[Rails.env]

#Load from ENV variable in production server
TWITTER_CONFIG = ENV['TWITTER_CONFIG']