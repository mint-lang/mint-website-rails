class VersionEntities < ActiveInteraction::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  object :version, class: Version
  string :current, default: nil
  string :search, default: nil

  def execute
    all =
      process('components') +
        process('modules') +
        process('stores')

    filtered = []

    all.each do |item|
      entities =  []

      if search.present?
        matches =
          item[:name].downcase.include?(search.downcase)

        item[:entities].each do |item|
          if item[:name].downcase.include?(search.downcase)
            entities << item
          end
        end

        if matches || entities.any?
          filtered << item
        end
      else
        if current == item[:name]
          filtered << item
          entities = item[:entities]
        else
          filtered << item
        end
      end

      item[:entities] = entities.sort_by { |item| item[:name] }

    end

    filtered.sort_by { |item| item[:name] }
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

      entities =
        entities
          .each do |entity|
            entity[:link] =
              repo_entity_path(version.package.author,
                             version.package.repo,
                             version,
                             category,
                             item['name'],
                             anchor: entity[:name])
          end

      {
        name: item['name'],
        type: category.singularize,
        entities: entities,
        category: category,
        link: repo_entity_path(version.package.author,
                               version.package.repo,
                               version,
                               category,
                               item['name']),
      }
    end
  end
end
