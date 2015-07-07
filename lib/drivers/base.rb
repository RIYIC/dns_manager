require 'abstract_interface'

module Driver::Base

    include AbstractInterface
    
    needs_implementation (%W{

        :create_domain
        :get_domain
        :remove_domain
        :create_record
        :remove_record
        :update_record
        :get_record
    })

    def required_args(params, required=())

        required.each do |required_param|

            raise "Required arg #{required_param} not present" unless params.has_key?(required_param)
        end


    end
end
