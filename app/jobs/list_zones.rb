class ListZones < ProviderJobBase

    queue_as :instantanea

    def perform(args={})

        raise "Falta parametro necesario :domain" unless args.include?(:domain)

        domain = get_provider(args).domains.find_by_name!(
            args[:domain]
        )

        provider_records = []

        get_driver(args).get_records(args).each do |r|

            provider_records.push(
                r.to_hash

                #{
                #    name: r.name,
                #    data: r.data,
                #    type: r.type,
                #    priority: r.priority,
                #    port: r.port,
                #    weight: r.weight,
                #    id: r.id
                #
                #}
            )

        end

        provider_records
            

    end

end
