class Domain < ActiveRecord::Base
    has_many :records,dependent: :destroy

    belongs_to :user

    validates :name, presence: true, uniqueness: true

    validates :user_id, presence: true

end
