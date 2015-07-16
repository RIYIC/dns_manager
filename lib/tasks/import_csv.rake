require 'csv'

# ispconfig query:
# SELECT  soa.origin, rr.name, rr.type, rr.data, rr.aux, rr.ttl, rr.active, rr.stamp, rr.serial 
# INTO OUTFILE '/tmp/result.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n' 
# FROM dns_rr as rr, dns_soa as soa WHERE soa.id = rr.zone
#
desc 'Import dns records from csv.'
task :import_csv => :environment do
    file = ARGV[1] or raise 'A csv filepath must be specified'
    unless File.exists?(file)
        raise "File #{file} not found"
    end

    username = ARGV[2] or raise 'Needs a username or user uuid to import the records'

    user = User.find_by_uuid(username) || User.find_by_name(username)

    raise "User #{username} not found" unless user

    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers:false)

    # 0 : domain
    # 1 : zone name
    # 2 : zone type
    # 3 : destination
    # 4 : extra
    # 5 : ttl
    # 6 : active (Y|N)
    # 7 : modification timestamp
    # 8 : serial

    csv.each do |row|
        (domain, name, type, data, extra, ttl, active, modification_timestamp, serial) = row

        puts "Antes: #{domain}, #{name}, #{type}, #{extra}, #{active}"
        # quitamos o punto final no dominio
        # senon no o acepta o proveedor
        domain.gsub!(/\.$/, '')

        # quitamos o dominios, por si o ten
        name.gsub!(/\.#{domain}\.?$/, '')
        name = '@' if name == domain

        # correximos extra
        extra = fix_extra(extra, type)

        # correximos erros leves no data
        data = fix_data(data, type)


        puts "Despues:#{domain}, #{name}, #{type}, #{extra}, #{active}"

        d = Domain.find_by_name(domain)

        if d.nil?
            begin
                CreateDomain.perform_now(name: domain, user_id: user.id)
            rescue Exception => e
                puts "Error creando domain #{domain}: #{e}"

            end
        end

        # recargamos o dominio
        d = Domain.find_by_name(domain)

        z = Record.find_by(domain_id: d.id, name: name, zone_type: type, data: data)

        if z.nil?
            begin

                CreateZoneRecord.perform_now(
                    domain: domain,
                    name: name,
                    zone_type: type,
                    data: data,
                    priority: extra,
                    active:active,
                    modification_timestamp: modification_timestamp
                )
            rescue Exception => e
                puts "Error creando zona #{name} en dominio #{dominio} con data #{data}. #{e}"
            end
        else
            z.priority = extra
            z.active = active
            z.modification_timestamp = modification_timestamp

            z.save!
        end

        # if(d.nil?)
        #     d = Domain.new(name: domain)
        #     d.save!
        # end
        #
        # z = Record.find_by(domain_id: d.id, name: name, zone_type: type, data: data)
        #
        # if(z.nil?)
        #     z = d.records.new(
        #         name: name,
        #         zone_type: type,
        #         data: data,
        #         priority: extra,
        #         active: active,
        #         modification_timestamp: modification_timestamp
        #     )
        # else
        #     z.priority = extra
        #     z.active = active
        #     z.modification_timestamp = modification_timestamp
        # end
        #
        # z.save!
        
    end

end


def fix_data(data, type)

    if type == 'CNAME' || type == 'MX'

        data += '.' unless data =~ /\.$/
    end

    data

end


def fix_extra(extra, type)

    return nil if (extra =~ /^0$/ && type != 'MX')
    
    return "10" if (extra == nil && type == 'MX')

    extra

end
