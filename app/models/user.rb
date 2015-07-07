class User < ActiveRecord::Base

    has_many :domains, dependent: :destroy

end
