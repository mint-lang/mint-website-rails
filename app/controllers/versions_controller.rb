class VersionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :find_version, only: [:version, :entity]
  before_action :set_title

  def entity
    @category = params[:category]
    @entity = params[:entity]

    find_entities

    respond_to do |format|
      format.html { render :show }
      format.js { render partial: 'sidebar' }
    end
  end

  def show
    @version =
      Package
      .find_by_repository("#{params[:author]}/#{params[:repo]}")
      .latest_version

    find_entities

    unless @version.readme
      @category = 'modules'
      @entity = @version.documentation['modules'].first['name']
    end

    respond_to do |format|
      format.html { render :show }
      format.js { render partial: 'sidebar' }
    end
  end

  def version
    find_entities

    respond_to do |format|
      format.html { render :show }
      format.js { render partial: 'sidebar' }
    end
  end

  def set_title
    title_parts = [
      params[:author],
      params[:repo],
      params[:version],
      params[:module]
    ]

    set_meta_tags(title: title_parts.compact.join(' - '))
  end

  def find_version
    @version =
      Package
      .find_by_repository("#{params[:author]}/#{params[:repo]}")
      .versions
      .find_by_version params[:version]
  end

  def find_entities
    @items = VersionEntities.run!(version: @version, search: params[:search], current: params[:entity])
  end
end
