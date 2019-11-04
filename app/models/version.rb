# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  package_id     :integer
#  version        :string
#  package_json   :json
#  documentation  :json
#  readme         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  effect_manager :boolean
#

class Version < ActiveRecord::Base
  default_scope do
    where("documentation::text != '[]'")
      .order("string_to_array(version, '.')::int[] desc")
  end

  belongs_to :package

  def to_param
    version
  end

  def description
    mint_json['description']
  end

  def dependencies
    mint_json['dependencies'].to_h
  end

  def experimental?
    (Semantic::Version.new version).major < 1
  end
end
