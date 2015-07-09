class ClustersController < ApplicationController
  before_action :set_cluster, only: [:show, :edit, :update, :destroy]

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

  # GET /clusters/1
  # GET /clusters/1.json
  def show
  end

  # GET /clusters/new
  def new
    @cluster = Cluster.new
  end

  # GET /clusters/1/edit
  def edit
  end

  # POST /clusters
  # POST /clusters.json
  def create
    @cluster = Cluster.new(cluster_params)

    respond_to do |format|
      if @cluster.save
        format.html { redirect_to @cluster, notice: 'Cluster was successfully created.' }
        format.json { render :show, status: :created, location: @cluster }
      else
        format.html { render :new }
        format.json { render json: @cluster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clusters/1
  # PATCH/PUT /clusters/1.json
  def update
    respond_to do |format|
      if @cluster.update(cluster_params)
        format.html { redirect_to @cluster, notice: 'Cluster was successfully updated.' }
        format.json { render :show, status: :ok, location: @cluster }
      else
        format.html { render :edit }
        format.json { render json: @cluster.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clusters/1
  # DELETE /clusters/1.json
  def destroy
    @cluster.destroy
    respond_to do |format|
      format.html { redirect_to clusters_url, notice: 'Cluster was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cluster
      @cluster = Cluster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cluster_params
      params[:cluster]
    end
end
