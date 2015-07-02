require 'yaml'

ENV_FILENAME = '/home/env'

desc "Syncronize database domain records with provider account" 
task :sync_records => :environment do
    
    provider = ARGV[1] || 'digitalocean'

    credentials = YAML.load(File.read(ENV_FILENAME)) if File.exists?(ENV_FILENAME)

    raise "Credential not found" unless credentials.has_key?(provider)

    client = DropletKit::Client.new(access_token: credentials[provider], per_page: 1000)

    domains_in_provider = []

    client.domains.each do |d|
        domains_in_provider.push(d)
    end

    puts "Domains in provider: " + domains_in_provider.map{|d| d.name}.size.to_s

    Domain.all.each do |d|

        unless domains_in_provider.any?{|dp| dp.name == d.name}

            puts "creando #{d.name}"

            create_domain(client, d)

            # borramos a zona @ para poder apuntala a outro lado
            # se crea por defecto ao dar de alta o dominio
            drop_zone(client, d, '@')

            create_records(client, d)

        end
        
    end
end


def create_domain(client, domain)
    d = DropletKit::Domain.new(
        name: domain.name,
        ip_address: '95.85.33.24',
    )

    check_response(client.domains.create(d))

end


def drop_zone(client, domain, zone='@', type='A')

    client.domain_records.all(for_domain: domain.name).each do |record|

        next unless(record.name == zone && record.type == type)
        
        client.domain_records.delete(for_domain: domain.name, id: record.id)
    
    end

end


def create_records(client, domain)

    domain.records.each do |record|
        puts "creando record #{record.inspect}"

        provider_record = DropletKit::DomainRecord.new(
            type: record.zone_type,
            name: record.name,
            data: record.data,
        )

        provider_record.priority = 10 if(record.zone_type == 'MX')

        response = client.domain_records.create(provider_record, for_domain: domain.name)

        check_response(response)
        
    end
end

def check_response(response)
    return response unless(response.class == String)
        
    unless JSON.parse(response)["id"] =~ /^\d+$/
        raise "ERROR: #{response}"
    end
end


