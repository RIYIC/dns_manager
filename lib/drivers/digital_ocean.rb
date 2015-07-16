require 'json'
require 'droplet_kit'
require 'abstract_interface'
require 'drivers/base'

module Driver
    class DigitalOcean < Driver::Base

        include AbstractInterface

        DEFAULT_DOMAIN_IP_ADDRESS = '95.85.33.24'

        def initialize(credentials)

            @client = DropletKit::Client.new(
                access_token: credentials
            )

        end

        def create_domain(args)

            required_args(args, :name)

            # en digitalocean, se crea obligatoriamente por defecto a zona @
            # ao dar de alta un domain
            d = DropletKit::Domain.new(
                name: args[:name],
                ip_address: args[:ip_address] || DEFAULT_DOMAIN_IP_ADDRESS,
            )

            check_response(@client.domains.create(d))

            # eliminamos zona @
            remove_records(
                domain: args[:name],
                name: '@',
                zone_type: 'A'
            )

            return d

        end


        def create_domain_with_dns(args)
            required_args(args, :name, :dns_servers)

            d = create_domain(args)

            remove_records(
                domain: args[:name],
                name: '@',
                zone_type: 'NS'
            )

            args[:dns_servers].each do |zone|

                create_record(
                    domain: args[:name],
                    name: '@',
                    zone_type: 'NS',
                    data: zone
                )

            end

            return d

        end

        def get_domain(args)

            required_args(args, :name)

            # devolvemos un obxeto DropletKit::DomainResource
            check_response(
                @client.domains.find(name: args[:name])
            )

        end

        def remove_domain(args)

            required_args(args, :name)

            check_response(
                @client.domains.delete(name: args[:name])
            )

        end


        def create_record(args)

            required_args(
                args,
                :domain,
                :name,
                :zone_type,
                :data
            )


            provider_record = DropletKit::DomainRecord.new(
                type: args[:zone_type],
                name: args[:name],
                data: args[:data],
                priority: args[:priority],
                port: args[:port],
                weight: args[:weight]
            )

            response = @client.domain_records.create(
                provider_record,
                for_domain: args[:domain]
            )

            # devolvemos a referencia do proveedor ao record
            # neste caso o "id"
            check_response(response).id

        end


        def remove_record(args)

            required_args(
                args,
                :provider_ref,
                :domain
            )

            check_response(
                @client.domain_records.delete(
                    id: args[:provider_ref],
                    for_domain: args[:domain]
                )
            )

        end


        def remove_records(args)
            required_args(args,:domain)

            check_response(

                @client.domain_records.all(for_domain: args[:domain])

            ).each do |record|

                next unless (!args.include?(:name) || record.name == args[:name])
                next unless(!args.include?(:type) || record.type == args[:zone_type])
                next unless(!args.include?(:data) || record.data == args[:data])

                check_response(
                    @client.domain_records.delete(
                                          for_domain: args[:domain],
                                          id: record.id
                    )
                )

            end
        end



        def update_record(args)

            required_args(
                args,
                :domain,
                :provider_ref,

                :data,
                :name
            )

            record = get_record(args)

            record.name = args[:name] if args.include?(:name)
            record.data = args[:data] if args.include?(:data)

            check_response(
                @client.domain_records.update(
                                          record: record,
                                          for_domain: args[:domain],
                                          id: record.id

                )
            )



        end

        def get_record(args)
            required_args(
                args, :provider_ref,:domain
            )


            # return a DropletKit::DomainRecord
            check_response(
                @client.domain_records.find(

                    id: args[:provider_ref],
                    for_domain: args[:domain]
                )
            )
        end


        private

        def check_response(response)

            return response unless(response.class == String)

            unless JSON.parse(response)['id'] =~ /^\d+$/
                raise "ERROR: #{response}"
            end
        end

    end



end
