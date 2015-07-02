require 'csv'

# ispconfig query:
# SELECT  soa.origin, rr.name, rr.type, rr.data, rr.aux, rr.ttl, rr.active, rr.stamp, rr.serial 
# INTO OUTFILE '/tmp/result.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n' 
# FROM dns_rr as rr, dns_soa as soa WHERE soa.id = rr.zone
#
desc "Import dns records from csv." 
task :import_csv => :environment do
    file = ARGV[1] or raise "A csv filepath must be specified"
    unless File.exists?(file)
        raise "File #{file} not found"
    end

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

        # quitamos o punto final no dominio
        # senon no o acepta o proveedor
        domain.gsub!(/\.$/, '')

        # quitamos o dominios, por si o ten
        name.gsub!(/\.#{domain}\.?$/, '')
        name = '@' if name == domain


        extra = nil if extra == '0'
        puts "#{domain}, #{name}, #{type}, #{extra}, #{active}"

        d = Domain.find_by_name(domain)

        if(d.nil?)
            d = Domain.new(name: domain)
            d.save!
        end

        z = Record.find_by(domain_id: d.id, name: name, zone_type: type, data: data)

        if(z.nil?)
            puts "creando zona #{name} tipo: #{type}"
            z = d.records.new(
                name: name,
                zone_type: type,
                data: data,
                extra: extra,
                active: active,
                modification_timestamp: modification_timestamp
            )
        else
            z.extra = extra
            z.active = active
            z.modification_timestamp = modification_timestamp
        end

        z.save!
        
    end

end
