class ReservedLocker < ActiveRecord::Base
  validates :size, inclusion: { in: %w(Small Medium Large),
                                message: "%{value} is not a valid size" }
  validates :number, numericality: true
  validates :size, :number, presence: true
end
