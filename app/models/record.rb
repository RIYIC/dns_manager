class Record < ActiveRecord::Base

    belongs_to :domain

    validates :domain_id, presence: true
    validates :name, presence: true
    validates :zone_type, presence: true
    validates :data, presence: true

    validates :zone_type , 
        inclusion: {
            in:  %w(
                A 
                CNAME  
                MX
                NS 
                TXT 
                SRV
                PTR
            ),
            message: "'%{value}' is not a valid zone_type"
        }


end
