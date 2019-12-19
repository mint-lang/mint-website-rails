# == Schema Information
#
# Table name: sandboxes
#
#  id         :string           not null, primary key
#  content    :string
#  title      :string
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Sandbox < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  after_commit :clear_cache

  def clear_cache
    Redis.current.hdel('sandboxes', id)
  end
end
