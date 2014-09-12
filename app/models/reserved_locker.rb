class ReservedLocker < ActiveRecord::Base
  validates :size, inclusion: { in: %w(Small Regular Large),
                                message: "%{value} is not a valid size" }
  validates :number, numericality: true
  validates :size, :number, presence: true
end
