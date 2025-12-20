class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :body, presence: true

  default_scope { order(created_at: :asc) }
end
