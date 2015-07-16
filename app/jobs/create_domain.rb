require 'driver'
class CreateDomain < ActiveJob::Base

    DNS_SERVERS = %W{
        ns1.riyic.com.
        ns2.riyic.com.
        ns3.riyic.com.
    }

    queue_as :altas
    
    def perform(args={})

        provider = args[:provider] || Rails.configuration.x.default_provider

        driver = Driver.get(provider: provider)

        args[:dns_servers] = DNS_SERVERS

        domain = driver.create_domain_with_dns(args)

        d = Provider.find_by_slug!(provider).
                domains.create!(name: args[:name], user_id: args[:user_id])


        DNS_SERVERS.each do |dns|

            d.records.create!(
                         name: '@',
                         zone_type: 'NS',
                         data: dns
            )

        end

    end


end
