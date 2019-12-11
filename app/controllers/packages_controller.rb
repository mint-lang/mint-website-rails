class PackagesController < ApplicationController
  def landing
    set_meta_tags title: 'Find and read documentation of Elm packages.'

    if params[:search]
      @packages =
        Package
        .search
        .where(
          "mint_json->>'description' ILIKE ? OR repository ILIKE ?",
          "%#{params[:search]}%",
          "%#{params[:search]}%")

      render :search
    else
      @packages =
        Package
        .initial
        .includes(:latest_version)
        .order(stars: :desc)
        .limit(30)

      @recent =
        Package
        .initial
        .includes(:latest_version)
        .recent
        .limit(30)
    end
  end

  def recent
    set_meta_tags title: 'Recently Updated Packages'

    @packages =
      Package
      .includes(:latest_version)
      .recent
      .limit(30)
  end

  def by_author
    set_meta_tags title: "Packages by #{params[:author]}"

    @packages =
      Package
      .initial
      .includes(:latest_version)
      .where('repository ILIKE ?', "#{params[:author]}%")
  end

  def index
    set_meta_tags title: 'All packages'

    @packages =
      Package
        .initial
        .includes(:latest_version)
        .order(stars: :desc)
  end
end
