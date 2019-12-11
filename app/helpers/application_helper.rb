module ApplicationHelper
  def search_highlighted(value)
    if params[:search]
      value.to_s.gsub(Regexp.new(params[:search], 'i'), '<b>\0</b>').html_safe
    else
      value
    end
  end

  def repo_entity_path(author, repo, version, category, entity, *args)
    if author == "mint-lang" && repo == "core"
      api_entity_path(category, entity, *args)
    else
      _repo_entity_path(author, repo, version, category, entity, *args)
    end
  end
end
