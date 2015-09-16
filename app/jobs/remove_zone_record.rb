class RemoveZoneRecord < ProviderJobBase

    def perform(args={})

        raise "Falta parametro necesario :domain" unless args.include?(:domain)

        domain = Domain.find_by_name!(args[:domain])


        if args.include?(:provider_ref)
            record = domain.records.find_by_provider_ref(args[:provider_ref])
        else
            record = domain.records.find_by(
                name: args[:name], 
                zone_type: args[:zone_type], 
                data: args[:data]
            )
        end


        a = driver.delete_record(record)

        record.destroy!
    end
end
