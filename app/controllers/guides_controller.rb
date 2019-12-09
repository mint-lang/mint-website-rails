class GuidesController < ApplicationController
  def page
    path =
      File.join(Rails.root, 'app', 'views', 'guides', 'pages', params[:page] + ".haml")

    if File.exist?(path)
      @page = 'guides/pages/' + params[:page]
    else
      index =
        File.join(Rails.root, 'app', 'views', 'guides', 'pages', params[:page], "index.haml")

      if File.exist?(index)
        @page = 'guides/pages/' + params[:page] + '/index'
      else
        redirect_to '/guide'
      end
    end
  end

  def index
  end
end
