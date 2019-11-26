class GuidesController < ApplicationController
  def page
    @cache ||= {}
    @cache[params[:page]] ||= begin
      path =
        File.join(Rails.root, 'app', 'guides', params[:page] + ".md")

      if File.exist?(path)
        GitHub::Markup.render('page.md', File.read(path)).html_safe
      else
        index =
          File.join(Rails.root, 'app', 'guides', params[:page], "index.md")

        if File.exist?(index)
          GitHub::Markup.render('page.md', File.read(index)).html_safe
        else
          redirect_to '/guide'
        end
      end
    end
  end

  def index
  end
end
