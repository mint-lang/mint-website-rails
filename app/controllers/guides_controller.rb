class GuidesController < ApplicationController
  def page
    @cache ||= {}
    @cache[params[:page]] ||= begin
      path =
        File.join(Rails.root, 'app', 'guides', params[:page] + ".md")

      if File.exist?(path)
        contents =
          File.read(path)

        GitHub::Markup.render('page.md', contents).html_safe
      else
        redirect_to '/guide'
      end
    end
  end

  def index
  end
end
