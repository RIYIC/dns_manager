class Domain < ActiveRecord::Base
    has_many :records,dependent: :destroy

    validates :name, presence: true, uniqueness: true

end
