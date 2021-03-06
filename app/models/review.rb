# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  title      :string
#  body       :text
#  rating     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comic_id   :integer
#  series_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_reviews_on_comic_id   (comic_id)
#  index_reviews_on_series_id  (series_id)
#  index_reviews_on_user_id    (user_id)
#

class Review < ApplicationRecord
    belongs_to :comic , optional: true
    belongs_to :series, optional: true
    belongs_to :critic,
        class_name: 'User',
        foreign_key: 'user_id',
        inverse_of: :reviews
    has_one :discussion, dependent: :destroy
    validates :body,:rating,:title, presence:true
    validates :title, uniqueness: true
    before_validation :normalize
    after_save :create_discussions

    def normalize
        title.downcase!
    end

    def create_discussions
        Discussion.create!(review_id: self.id)
    end

end
