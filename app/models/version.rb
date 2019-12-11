# == Schema Information
#
# Table name: versions
#
#  id            :bigint           not null, primary key
#  package_id    :bigint
#  version       :string
#  readme        :text
#  mint_json     :json
#  documentation :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Version < ActiveRecord::Base
  default_scope do
    where("documentation::text != '{}'")
      .order(Arel.sql("string_to_array(version, '.')::int[]") => :desc)
  end

  belongs_to :package

  def to_param
    version
  end

  def name
    mint_json['name']
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
