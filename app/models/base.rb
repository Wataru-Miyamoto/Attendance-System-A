class Base < ApplicationRecord
  
  validates :base_name, presence: true
  validates :base_type, presence: true
  
end
