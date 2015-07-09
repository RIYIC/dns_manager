require 'abstract_interface'

module Driver
    class Base

        include AbstractInterface

        needs_implementation(:create_domain)
        needs_implementation(:get_domain)
        needs_implementation(:remove_domain)
        needs_implementation(:create_record)
        needs_implementation(:remove_record)
        needs_implementation(:update_record)
        needs_implementation(:get_record)



        def required_args(params, *required)

            required.each do |required_param|

                raise "Required arg #{required_param} not present" unless params.has_key?(required_param)
            end


        end
    end

end
