module GuidesHelper
  def toc_link(name, page)
    active_link_to name, "/guide#{page}", class: :toc__page, active: :exact
  end
end
