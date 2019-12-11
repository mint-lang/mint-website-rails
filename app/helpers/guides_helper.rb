module GuidesHelper
  def toc_link(name, page)
    active_link_to "/guide#{page}", class: :toc__page, active: :exact do
      tag.div name
    end
  end
end
