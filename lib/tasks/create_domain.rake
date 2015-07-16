desc 'Create domain in provider with default records'

task :create_domain => :environment do

    dominio_crear = ARGV[1]
    usuario = ARGV[2]

    raise 'Falta o dominio a crear' if(dominio_crear.nil?)
    raise 'Falta o usuario asociado ao dominio a crear' if(usuario.nil?)

    user = User.find_by_uuid!(usuario) || User.find_by_name!(usuario)

    CreateDomain.perform_now(name: dominio_crear, user_id: user.id )

end