require 'json'
require 'droplet_kit'
require 'abstract_interface'

class Driver::DigitalOcean < Driver::Base
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
        
    end


    def create_domain_with_dns(args)
        required_args(args, :name, :dns_servers)

        d = create_domain(args)

        args[:dns_servers].each do |zone|

            remove_records(
                domain: args[:name],
                name: '@',
                zone_type: 'NS'
            )


            create_record(
                domain: args[:name],
                name: '@',
                zone_type: 'NS',
                data: zone
            )

        end


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

        # filtros opcionais
        args[:name] = nil unless(args.include?(:name))
        args[:zone_type] = nil unless(args.include?(:zone_type))
        args[:data] = nil unless(args.include?(:data))

        check_response(

            @client.domain_records.all(for_domain: args[:domain])

        ).each do |record|

            next unless (record.name == args[:name])
            next unless(record.type == args[:zone_type])
            next unless(record.data == args[:data])

            check_response(
                @client.domain_records.delete(
                                      for_domain: args[:domain],
                                      id: record.id
                )
            )

        end
    end



    def update_record
    end

    def get_record
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
