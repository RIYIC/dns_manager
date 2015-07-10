class Provider < ActiveRecord::Base

    has_many :domains

    validates :slug, presence: true, uniqueness: true

    validates :name, presence: true



end
