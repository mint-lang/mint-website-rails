class Array
  def intersperse(separator)
    (inject([]) { |a, v| a + [v, separator] })[0...-1]
  end
end

module VersionsHelper
  def body_html
    if @entity
      docs =
        @version
          .documentation[@category]
          .find { |item| item['name'] == @entity }

      case @category
      when 'components'
        render partial: 'component', locals: { docs: docs }
      when 'providers'
        render partial: 'provider', locals: { docs: docs }
      when 'records'
        render partial: 'record', locals: { docs: docs }
      when 'enums'
        render partial: 'enum', locals: { docs: docs }
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
