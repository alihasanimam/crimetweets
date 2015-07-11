class Classifier

  def self.count_crimes(types = ['crime'], limit=100000)
    results = {benchmark: {}}
    result_traditional = Hash[types.product([0])]
    result_aggregation = Hash[types.product([0])]
    result_map_reduce = Hash[types.product([0])]

    # Solution using traditional way
    results[:benchmark][:traditional] = Benchmark.measure{
      Tweet.only(:tweet_text).limit(limit).each do |tweet|
        types.each do |type|
          if tweet.tweet_text.match(/#{type}/i)
            result_traditional[type] += 1
          end
        end
      end
      puts "Traditional: #{result_traditional}"
    }.real


    # Solution using aggregation framework
    results[:benchmark][:aggregation] = Benchmark.measure{
      max_tweet = Tweet.offset(limit).first || Tweet.last
      types.each do |type|
        result_aggregation[type] += Tweet.where(:id.lt => max_tweet.id, tweet_text: /#{type}/i).count
      end
      puts "Aggregation: #{result_aggregation.inspect}"
    }.real * 2


    # Solution using map reduce
    map = %Q{
      function(){
          var tweet = this;
          #{types.to_s}.forEach(function(key){
            if(tweet.tweet_text.search(new RegExp(key, 'i')) > -1)
              emit(key, 1);
          });
      }
    }

    reduce = %Q{
      function(key, values){
        var count = 0;
        values.forEach(function(value) {
          count += value;
        });
        return count;
      }
    }

    results[:benchmark][:mapreduce] = Benchmark.measure{
      Tweet.limit(limit).map_reduce(map, reduce).out(inline: true).each do |result|
        result_map_reduce[result['_id']] += result['value']
      end
      puts "Map Reduce: #{result_map_reduce}"
    }.real

    results[:data] = result_aggregation
    return results
  end

  def self.count_by_country(type, limit = 10000)
    map = %Q{
      function(){
          if(this.tweet_text.search(new RegExp('#{type}', 'i')) > -1)
            emit(this.tweet_place['country'], 1);
      }
    }

    reduce = %Q{
      function(key, values){
        var count = 0;
        values.forEach(function(value) {
          count += value;
        });
        return count;
      }
    }

    results = {}
    Tweet.where(:tweet_place.ne => nil).limit(limit).map_reduce(map, reduce).out(inline: true).each do |result|
      results[result['_id']] = result['value']
    end
    return results
  end



  def self.generate_training_set
    File.open("training.txt", "w") do |file|
      Tweet::CRIMES.each do |type|
        tweets = []
        Tweet.only(:tweet_text).where(tweet_text: /#{type}/i).limit(100).each do |tweet|
          unless tweets.include? tweet.tweet_text
            tweets << tweet.tweet_text
            file.write 'Bayes.train(' + tweet.tweet_text.to_json + ", '#{type}');\n"
          end
        end
        file.write "\n\n\n"
      end
    end
  end
end
