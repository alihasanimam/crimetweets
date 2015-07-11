class ClassifiersController < ApplicationController
  # before_action :set_classifier, only: [:show, :edit, :update, :destroy]

  # GET /classifications
  # GET /classifications.json
  def tweets
    if params[:types].present?
      @results = Classifier.count_crimes params[:types]
    end
  end

  def text

  end

  def country
    if params[:type].present?
      @result = Classifier.count_by_country params[:type]
    end
  end
end
