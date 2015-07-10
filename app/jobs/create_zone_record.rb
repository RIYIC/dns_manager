require 'driver'

class CreateZoneRecord < ActiveJob::Base

    def perform(args={})
        provider = args[:provider] || Rails.configuration.x.default_provider

        driver = Driver.get(provider: provider)

        domain = Domain.find_by_name(args[:domain])

        provider_ref = driver.create_record(args)

        domain.records.create!(

            name: args[:name],
            zone_type: args[:zone_type],
            data: args[:data],
            priority: args[:priority],
            weight: args[:weight],
            port: args[:port],
            active: args[:active],
            modification_timestamp: args[:modification_timestamp],
            provider_ref: provider_ref

        )


    end

end
