class PackagesController < ApplicationController
  def handle_add
    @outcome = SyncPackage.run(repository: params[:repository])

    if @outcome.valid?
      author, repo =
        params[:repository].split("/", 2)

      redirect_to repo_root_path(author, repo)
    else
      render :add
    end
  end

  def landing
    set_meta_tags title: 'Packages'

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
