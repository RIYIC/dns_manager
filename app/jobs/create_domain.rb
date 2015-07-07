class CreateDomain < ActiveJob::Base
    DNS_SERVERS = [%W{
        ns1.riyic.com
        ns2.riyic.com
        ns3.riyic.com
    }]

    queue_as :altas
    
    def perform(*args)
        
        driver = Driver.new(provider: Rails.configuration.x.provider)

        args[:dns_servers] = DNS_SERVERS

        driver.create_domain_with_dns(args)

        d = Domain.new(name: args[:name]).save!

        DNS_SERVERS.each do |dns|

            d.records.new(
                         name: '@',
                         zone_type: 'NS',
                         data: dns
            ).save!

        end

    end


end
