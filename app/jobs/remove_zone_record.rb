require 'driver'


class RemoveZoneRecord < ActiveJob::Base

    def perform(args={})
        provider = args[:provider] || Rails.configuration.x.default_provider

        driver = Driver.get(provider: provider)

        domain = Domain.find_by_name!(args[:domain])

        domain.records.each{|r| puts "name: #{r.name}, type: #{r.zone_type}, data: #{r.data}"}


        records = []

        case args
        when args.include?(:all)
            records = domain.records
        when args.include?(:name)
            records = domain.records.find_by!(name: args[:name])
        when args.include?(:zone_type)
            records = domain.records.find_by!(zone_type: args[:zone_type])
        when args.include?(:data)
            records = domain.records.find_by!(data: args[:data])
        else
            raise "error"
	end

        domain.records.find_by_id!()

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
