namespace :twitter do
  desc 'Thread 1: Fetch tweets from tweeter.'
  task collect_tweets_thread_1: :environment do
    request_limit = 10
    q = 'arson OR burglary OR crime OR "domestic abuse" OR embezzlement OR felony OR forgery OR "human trafficking" OR kidnapping OR larceny'
    client = Twitter::REST::Client.new({consumer_key: TWITTER_CONFIG['consumer_key_1'], consumer_secret: TWITTER_CONFIG['consumer_secret_1']})

    request_limit.times do
      last_tweet = Tweet.where(:thread => 1).last
      max_id = last_tweet.present? ? last_tweet.tweet_id : 888888888888888888
      puts "Last Tweet: #{max_id}"

      client.search(q, result_type: 'recent', max_id: max_id).take(100).each do |result|
        tweet = Tweet.new(thread: 1)
        Tweet.attribute_names.each do |attr|
          if attr[0..5] == 'tweet_'
            tweet.public_send("#{attr}=", result.attrs[(attr[6..-1].to_sym)])
          end
        end
        tweet.save!
      end
    end
  end

  desc 'Thread 2: Fetch tweets from tweeter.'
  task collect_tweets_thread_2: :environment do
    request_limit = 10
    q = 'manslaughter OR "moral turpitude" OR murder OR prostitution OR receiving OR robbery OR stalking OR theft OR treason OR trespass'
    client = Twitter::REST::Client.new({consumer_key: TWITTER_CONFIG['consumer_key_2'], consumer_secret: TWITTER_CONFIG['consumer_secret_2']})

    request_limit.times do
      last_tweet = Tweet.where(:thread => 2).last
      max_id = last_tweet.present? ? last_tweet.tweet_id : 888888888888888888
      puts "Last Tweet: #{max_id}"

      client.search(q, result_type: 'recent', max_id: max_id).take(100).each do |result|
        tweet = Tweet.new(thread: 2)
        Tweet.attribute_names.each do |attr|
          if attr[0..5] == 'tweet_'
            tweet.public_send("#{attr}=", result.attrs[(attr[6..-1].to_sym)])
          end
        end
        tweet.save!
      end
    end
  end
end
