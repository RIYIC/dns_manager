require 'yaml'

ENV_FILENAME = '/home/env'

desc "Drop domain from provider" 
task :drop_domain => :environment do
    provider = 'digitalocean'
    
    dominio_borrar = ARGV[1]
    
    raise "Falta o dominio a borrar" if(dominio_borrar.empty?)

    credentials = YAML.load(File.read(ENV_FILENAME)) if File.exists?(ENV_FILENAME)

    raise "Credential not found" unless credentials.has_key?(provider)

    client = DropletKit::Client.new(access_token: credentials[provider])

    client.domains.all.each do |d|

        next unless (d.name == dominio_borrar || dominio_borrar =~ /^(todos|all)$/)

        p client.domains.delete(name: d.name)
    end
end
