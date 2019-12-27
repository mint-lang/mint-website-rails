class VersionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :find_version, only: [:version, :entity]

  def api
    params[:author] = 'mint-lang'
    params[:repo] = 'core'

    show
  end

  def api_entity
    params[:author] = 'mint-lang'
    params[:version] = '1.0.0'
    params[:repo] = 'core'

    find_version

    entity
  end

  def entity
    @category = params[:category]
    @entity = params[:entity]

    set_title

    find_entities

    respond_to do |format|
      format.html { render :show }
      format.js { render partial: 'sidebar' }
    end
  end

  def show
    package =
      Package
      .find_by_repository("#{params[:author]}/#{params[:repo]}")

    if package
      @version =
        package.latest_version

      if @version
        find_entities

        unless @version.readme
          @category = 'modules'
          @entity = @version.documentation['modules'].first['name']
        end

        set_title

        respond_to do |format|
          format.html { render :show }
          format.js { render partial: 'sidebar' }
        end
      else
        redirect_to packages_path
      end
    else
      redirect_to packages_path
    end
  end

  def version
    if @version
      find_entities

      set_title

      respond_to do |format|
        format.html { render :show }
        format.js { render partial: 'sidebar' }
      end
    else
      redirect_to packages_path
    end
  end

  def set_title
    set_meta_tags(title: [
      params[:author],
      params[:repo],
      @entity
    ])
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
