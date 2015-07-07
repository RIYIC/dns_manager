class CreateZoneRecord < ActiveJob::Base

    def perform(args={})

        driver = Driver.new(provider: Rails.configuration.x.provider)

        domain = Domain.find_by_name(args[:domain])

        provider_ref = driver.create_record(args)

        domain.records.new(

            name: args[:name],
            zone_type: args[:type],
            data: args[:data],
            priority: args[:extra],
            active: args[:active],
            modification_timestamp: args[:modification_timestamp],
            provider_ref: provider_ref

        ).save!


    end

end
