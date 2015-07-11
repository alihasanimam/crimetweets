class ClustersController < ApplicationController

  # GET /clusters
  # GET /clusters.json
  def slink
    if params[:type].present?
      @markers = Cluster.crime_locations(params[:type])
    end
  end

  def kmeans
    if params[:types].present?
      @colors = %W[#ff0000 #00ff00 #0000ff]
      @clusters = []
      params[:types].each do |type|
        results = Cluster.k_means(type).sort_by{|r| -r[1]['count']}[0..3]
        circles = []
        results.each do |result|
          circles << {
              lat: result[1]['coordinates'][1],
              lng: result[1]['coordinates'][0],
              radius: result[1]['distance'] * 111 * 1000
          }
        end
        @clusters << circles
      end
    end
  end
end
