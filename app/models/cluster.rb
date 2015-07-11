class Cluster
  include Mongoid::Document

  def self.crime_locations(type, limit = 100000)
    locations = []
    max_tweet = Tweet.offset(limit).first || Tweet.last
    tweets = Tweet.only(:tweet_place).where(:id.lt => max_tweet.id, tweet_text: /#{type}/i, :tweet_place.ne => nil).limit(limit)
    tweets.each do |tweet|
      coordinates = tweet.try('tweet_place').try(:[], 'bounding_box').try(:[], 'coordinates')
      if coordinates.present?
        coordinates.flatten!
        count = coordinates.size / 2
        lng = coordinates.each_slice(2).map(&:first).sum / count
        lat = coordinates.each_slice(2).map(&:last).sum / count
        locations << {lat: lat, lng: lng}
      end
    end
    return locations
  end

  def self.k_means(type, limit = 100000)
    centroids = [[52.012173, -113.678014], [37.387922, -111.217077], [36.967756, -96.451451], [43.149374, -73.424107], [31.747181, -88.189732], [-19.372978, -49.693638], [52.909830, -0.527743], [45.707254, 8.085538], [11.524596, 19.335538], [44.841382, 83.671476], [21.290808, 83.495694], [-22.754501, 147.304290]]
    5.times do
      map = %Q{
        function(){
          if(this.tweet_text.search(/#{type}/i) < 0) return;
          var min_distance = {key: [0, 0], value: 360};
          var mean = [0 , 0];
          var count = 0;
          this.tweet_place.bounding_box.coordinates[0].forEach(function(coordinates){
            mean[0] += coordinates[0];
            mean[1] += coordinates[1];
            count++
          });
          mean[0] = mean[0]/count;
          mean[1] = mean[1]/count;

          #{centroids.to_s}.forEach(function(centroid){
            var distance = Math.sqrt(Math.pow(centroid[0] - mean[0], 2) + Math.pow(centroid[1] - mean[1], 2));
            if (distance < min_distance.value){
              min_distance.key = centroid;
              min_distance.value = distance;
            }
          });
          emit(min_distance.key, {coordinates: mean, distance: min_distance.value, count: 1});
        }
      }

      reduce = %Q{
        function(key, values){
          var count = 0;
          var coordinates = [0, 0];
          var distance = 0;
          values.forEach(function(value) {
            coordinates[0] += value.coordinates[0] * value.count;
            coordinates[1] += value.coordinates[1] * value.count;
            distance += value.distance * value.count;
            count += value.count;
          });
          return {coordinates: [coordinates[0]/count, coordinates[1]/count], distance: distance/count, count: count};
        }
      }

      @results = {}
      Tweet.where(:tweet_place.ne => nil).limit(limit).map_reduce(map, reduce).out(inline: true).each do |result|
        @results[result['_id']] = result['value']
        centroids[centroids.index(result['_id'])] = result['value']['coordinates']
      end
      # puts @results.inspect
    end

    return @results
  end
end
