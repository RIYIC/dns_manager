require 'driver'


class UpdateZoneRecord < ActiveJob::Base

    def perform(args={})
        provider = args[:provider] || Rails.configuration.x.default_provider

        driver = Driver.get(provider: provider)

        domain = Domain.find_by_name!(args[:domain])

        domain.records.each{|r| puts "name: #{r.name}, type: #{r.zone_type}, data: #{r.data}"}

        record = domain.records.find_by!(name: args[:name], zone_type: args[:zone_type], data: args[:old_data])

        args[:provider_ref] = record.provider_ref

        a = driver.update_record(args)

        record.update!(
            data: args[:data],
            priority: args[:priority],
            weight: args[:weight],
            port: args[:port],
            active: args[:active] || record.active,
            modification_timestamp: DateTime.now

        )
    end
end