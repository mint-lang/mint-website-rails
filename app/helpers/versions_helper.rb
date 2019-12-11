class Array
  def intersperse(separator)
    (inject([]) { |a, v| a + [v, separator] })[0...-1]
  end
end

module VersionsHelper
  def components
    @version
      .documentation['components']
      .to_a
      .sort_by { |mod| mod['name'] }
  end

  def modules
    @version
      .documentation['modules']
      .to_a
      .sort_by { |mod| mod['name'] }
  end

  def stores
    @version
      .documentation['stores']
      .to_a
      .sort_by { |mod| mod['name'] }
  end

  def body_html
    if @entity
      docs =
        @version
          .documentation[@category]
          .find { |item| item['name'] == @entity }

      case @category
      when 'components'
        render partial: 'component', locals: { docs: docs }
      when 'modules'
        render partial: 'module', locals: { docs: docs }
      when 'stores'
        render partial: 'store', locals: { docs: docs }
      else
        ""
      end
    elsif @version.readme
      GitHub::Markup.render('readme.md', @version.readme)
    end
  end
end
