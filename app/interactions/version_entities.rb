class VersionEntities < ActiveInteraction::Base
  object :version, class: Version

  def execute
    (process('components') +
      process('modules') +
      process('stores'))
      .sort_by! { |item| item[:name] }
      .each { |item| item[:entities].sort_by! { |item| item[:name] } }
  end


  def process(category)
    version.documentation[category].to_a.map do |item|
      entities = []

      item['functions'].to_a.map do |entity|
        entities << {
          name: entity['name'],
          type: 'function',
        }
      end

      item['properties'].to_a.map do |entity|
        entities << {
          name: entity['name'],
          type: 'property'
        }
      end

      item['states'].to_a.map do |entity|
        entities << {
          name: entity['name'],
          type: 'state'
        }
      end

      {
        name: item['name'],
        entities: entities,
        category: category
      }
    end
  end
end
