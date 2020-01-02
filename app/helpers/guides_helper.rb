module GuidesHelper
  def pages
    GuidesController::PAGES
  end

  def guide_nav_previous(path, title)
    link_to "/guide#{path}", class: 'guide__nav__button' do
      octicon("chevron-left", width: 12) +
      tag.div do
        tag.label("Previous") +
        tag.span(title)
      end
    end
  end

  def guide_nav_next(path, title)
    link_to "/guide#{path}", class: 'guide__nav__button' do
      tag.div do
        tag.label("Next") +
        tag.span(title)
      end +
      octicon("chevron-right", width: 12)
    end
  end

  def guide_nav
    tag.div class: 'guide__nav' do
      capture_haml do
        yield
      end
    end
  end

  def toc_link(name, page)
    active_link_to "/guide#{page}", class: :toc__page, active: :exact do
      tag.div name
    end
  end
end
