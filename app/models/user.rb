class User < ApplicationRecord
  validates :name, :email, presence: true, if: -> { step == 1 }
  validates :age, numericality: { only_integer: true }, if: -> { step == 2 }
  validates :address, presence: true, if: -> { step == 3 }
end