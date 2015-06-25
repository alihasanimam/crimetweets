class Tweet
  include Mongoid::Document
  include Mongoid::Timestamps

  CRIMES = %W[arson burglary crime domestic\ abuse embezzlement felony forgery human\ trafficking kidnapping
          larceny manslaughter moral\ turpitude murder prostitution receiving robbery stalking theft treason trespass]


  field :tweet_metadata, type: Hash, default: {}
  field :tweet_id, type: Integer
  field :tweet_id_str, type: String
  field :tweet_created_at, type: String
  field :tweet_text, type: String
  field :tweet_source, type: String
  field :tweet_truncated, type: Boolean, default: false
  field :tweet_in_reply_to_status_id, type: Integer, default: nil
  field :tweet_in_reply_to_status_id_str, type: String, default: nil
  field :tweet_in_reply_to_user_id, type: Integer, default: nil
  field :tweet_in_reply_to_user_id_str, type: String, default: nil
  field :tweet_in_reply_to_screen_name, type: String, default: nil
  field :tweet_user, type: Hash, default: {}
  field :tweet_coordinates, type: Hash, default: {}
  field :tweet_place, type: Hash, default: {}
  field :tweet_contributors, type: Hash, default: {}
  field :tweet_is_quote_status, type: Boolean, default: false
  field :tweet_retweet_count, type: Integer, default: 0
  field :tweet_favorite_count, type: Integer, default: 0
  field :tweet_entities, type: Hash, default: {}
  field :tweet_favorited, type: Boolean, default: false
  field :tweet_retweeted, type: Boolean, default: false
  field :tweet_possibly_sensitive, type: Boolean, default: false
  field :tweet_lang, type: String, default: nil

  field :categories, type: String
  field :thread, type: Integer, default: nil

  index({ created_at: 1 }, {name: 'created_at_index' })

  def self.count_crimes(types = ['crime'], limit=1000)
    # Solution using traditional way
    # puts Benchmark.measure{
    #   result_traditional = Hash[types.product([0])]
    #   Tweet.only(:tweet_text).limit(limit).each do |tweet|
    #     types.each do |type|
    #       if tweet.tweet_text.match(/#{type}/i)
    #         result_traditional[type] += 1
    #       end
    #     end
    #   end
    #   puts "Traditional: #{result_traditional}"
    # }


    # Solution using aggregation framework
    puts Benchmark.measure{
      result_aggregation = Hash[types.product([0])]
      max_tweet = Tweet.offset(limit).first
      types.each do |type|
        result_aggregation[type] += Tweet.where(:id.lt => max_tweet.id, tweet_text: /#{type}/i).count
      end
      puts "Aggregation: #{result_aggregation.inspect}"
    }


    # Solution using map reduce
    # map = %Q{
    #   function(){
    #       var tweet = this;
    #       #{types.to_s}.forEach(function(key){
    #         if(tweet.tweet_text.search(new RegExp(key, 'i')) > -1)
    #           emit(key, 1);
    #       });
    #   }
    # }
    #
    # reduce = %Q{
    #   function(key, values){
    #     var count = 0;
    #     values.forEach(function(value) {
    #       count += value;
    #     });
    #     return count;
    #   }
    # }

    # puts Benchmark.measure{
    #   result_map_reduce = Hash[types.product([0])]
    #   Tweet.limit(limit).map_reduce(map, reduce).out(inline: true).each do |result|
    #     result_map_reduce[result['_id']] += result['value']
    #   end
    #   puts "Map Reduce: #{result_map_reduce}"
    # }
  end

  def self.collect_tweets
    request_limit = 1
    q = 'arson OR burglary OR crime OR "domestic abuse" OR embezzlement OR felony OR forgery OR "human trafficking" OR kidnapping OR larceny'
    client = Twitter::REST::Client.new({consumer_key: TWITTER_CONFIG['consumer_key_1'], consumer_secret: TWITTER_CONFIG['consumer_secret_1']})

    request_limit.times do
      last_tweet = Tweet.where(:thread => 1).last
      max_id = last_tweet.present? ? last_tweet.tweet_id : 888888888888888888
      #max_id = 619945063096721408
      puts "Last Tweet: #{max_id}"

      results = client.search(q, result_type: 'recent', max_id: max_id).take(100)
      results.each do |result|
        # tweet = Tweet.new(thread: 1)
        # Tweet.attribute_names.each do |attr|
        #   if attr[0..5] == 'tweet_'
        #     tweet.public_send("#{attr}=", result.attrs[(attr[6..-1].to_sym)])
        #   end
        # end
        # tweet.save!
      end
    end
  end
end