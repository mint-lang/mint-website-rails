class BlogController < ApplicationController
  before_action :find_posts

  def index
  end

  def post
    dir =
      File.join(Rails.root, 'app', 'views', 'blog', 'posts', "*#{params[:slug]}.haml")

    file = Dir.glob(dir, File::FNM_CASEFOLD).first

    if file
      @post = build_post(file)
    else
      redirect_to blog_path
    end
  end

  def build_post(path)
    basename =
      File.basename(path, '.*')

    return if basename.starts_with?("_")

    date, slug =
      basename.split('_')

    parsed =
      Date.parse(date)

    {
      formatted_date: parsed.strftime("%A, %B #{parsed.day.ordinalize}, %Y"),
      title: slug.split('-').join(' '),
      path: "blog/posts/#{File.basename(path)}",
      slug: slug.downcase,
      date: parsed,
    }
  end

  def find_posts
    @posts ||= begin
      dir =
        File.join(Rails.root, 'app', 'views', 'blog', 'posts', "*")

      @posts =
        Dir
        .glob(dir)
        .map { |file| build_post(file) }
        .compact

    end.sort_by { |item| item[:date] }.reverse
  end
end
