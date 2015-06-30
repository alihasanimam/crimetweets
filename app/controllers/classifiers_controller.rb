class ClassifiersController < ApplicationController
  # before_action :set_classifier, only: [:show, :edit, :update, :destroy]

  # GET /classifications
  # GET /classifications.json
  def tweets
    if params[:types].present?
      @results = Tweet.count_crimes params[:types]
    end
  end

  def text

  end

  def country
    if params[:type].present?
      @result = Tweet.count_by_country params[:type]
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_classifier
      @classifier = Classifier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def classifier_params
      params.require(:classifier).permit(:text)
    end
end
