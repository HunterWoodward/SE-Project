# == Schema Information
#
# Table name: comics
#
#  id           :integer          not null, primary key
#  title        :string
#  issue_number :integer
#  description  :text
#  comic_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  series_id    :integer
#  user_id      :integer
#
# Indexes
#
#  index_comics_on_series_id  (series_id)
#  index_comics_on_user_id    (user_id)
#

class Comic < ApplicationRecord
    belongs_to :series, optional: true
    belongs_to :author,
        class_name: 'User',
        foreign_key: 'user_id',
        inverse_of: :comics
    has_many :pages, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_one :discussion, dependent: :destroy
    validates :title, :description, :comic_type, presence:true
    validates :title, uniqueness: true
    validate :has_cover_image
    has_one_attached :cover
    before_validation :normalize
    after_save :create_discussions
    has_many :reccomendations   
    has_many :users, through: :reccomendations
    def has_cover_image
        if cover.attached? && !cover.content_type.in?(%w(image/jpeg image/png))
            errors.add(:cover, 'Is must be a JPEG or PNG file')
        elsif cover.attached? == false
            errors.add(:cover, 'Is Required')
        end
    end

    def count_pages
        pages.count
    end

    def normalize
        title.downcase!
        comic_type.downcase!
    end

    def pages=(images = [])
        (0...images.count).each do |i|
            self.pages.build(page_number:i+1, image:images[i])
        end
    end

    def create_discussions
        Discussion.create!(comic_id: self.id)
    end

    def average_review
        reviews = self.reviews
        if (reviews.count < 5)
            "N/A"
        else
            average = 0
            reviews.each do |r|
                average += r.rating
            end
            average = (average/reviews.count)
            average.to_s+" Stars"
        end
    end
end
