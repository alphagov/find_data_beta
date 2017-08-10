require 'uri'

class DatasetsController < ApplicationController
  include DatasetsHelper

  def show
    begin
      @dataset = current_dataset
      raise 'Metadata missing' if @dataset.title.empty?
    rescue
      render :template => "errors/not_found", :status => 404
    end

    @query = get_referrer_query

    unless @dataset.nil?
      @related_datasets = related_datasets(@dataset._id)
    end
  end

  private

  def current_dataset
    Dataset.get(params[:name])
  end

  def related_datasets(id)
    Dataset.related_to(id)
  end

  def get_referrer_query
    unless request.referer.nil?
      referer_host = URI(request.referer).host.to_s
      app_host = URI(request.host).to_s
      referer_query = URI(request.referer).query

      referer_query if referer_host == app_host
    end
  end
end
