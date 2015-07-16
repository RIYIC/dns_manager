require 'yaml'

env_filename = '/home/env'

desc 'Drop domain from provider'

task :drop_domain => :environment do

    no_borrar = %W{anavillar.net alvanel.es}

    provider = 'digital_ocean'
    
    dominio_borrar = ARGV[1]
    
    raise 'Falta o dominio a borrar' if(dominio_borrar.nil?)

    credentials = YAML.load(File.read(env_filename)) if ::File.exists?(env_filename)

    raise 'credential not found' unless credentials.has_key?(provider)

    client = DropletKit::Client.new(access_token: credentials[provider])

    client.domains.all.each do |d|

        next unless (d.name == dominio_borrar || dominio_borrar =~ /^(todos|all)$/)

        next if no_borrar.include?(d.name)

        p "Borrando dominio #{d.name}. Resultado: #{client.domains.delete(name: d.name)}"
    end
end
