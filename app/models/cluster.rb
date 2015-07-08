class Cluster
  include Mongoid::Document

  def self.crime_locations(type, limit = 100000)
    locations = []
    max_tweet = Tweet.offset(limit).first
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
end
