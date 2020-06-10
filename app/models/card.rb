class Card < ApplicationRecord
  TAGS = %w[Algorithms Arrays Bionary Data_Strctures Strings Symbol Hash Object Numbers Rules Loops Utilities Mathematics Methods While If...else Lists].freeze

  belongs_to :board
  has_many :records
  has_many :user, through: :records
  has_many :tags
  validates :title, presence: true
  validates :level, presence: true
  validates :result, presence: true

  def self.search_by(search_term)
    if search_term
      where("LOWER(title) LIKE :search_term",
      search_term: "%#{search_term.downcase}%")
    else
      all
    end
  end

end
