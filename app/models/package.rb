# == Schema Information
#
# Table name: packages
#
#  id         :bigint           not null, primary key
#  repository :string
#  stars      :integer
#  pushed_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Package < ActiveRecord::Base
  has_many :versions, dependent: :delete_all
  has_one :latest_version, class_name: :Version

  scope :recent, lambda {
    initial
      .order(pushed_at: :desc)
  }

  scope :search, lambda {
    initial
      .joins(:versions)
      .includes(:latest_version)
      .where("
        version =
          (SELECT   version
           FROM     versions
           WHERE    package_id = packages.id
           ORDER BY ? DESC limit 1)
        ", "string_to_array(version, '.')::INT[]")
      .distinct
      .order(stars: :desc)
  }

  scope :initial, lambda {
    where("repository != 'mint-lang/core'")
  }

  def author
    repository.split('/').first
  end

  def repo
    repository.split('/').last
  end

  def to_param
    repository
  end
end
