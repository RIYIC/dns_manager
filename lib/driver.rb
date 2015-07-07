require 'yaml'
require 'active_support/inflector'
require 'drivers/digital_ocean'

class Driver

    ENV_FILENAME = '/home/env'

    def initialize(options)
        
        @provider = options['provider'] || 'digital_ocean'
        
        @credentials = YAML.load(File.read(ENV_FILENAME)) if File.exists?(ENV_FILENAME)

        raise 'Credential not found' unless credentials.has_key?(@provider)

        Object.const_get("Driver::#{@provider.camelize}").
            new(credential: credentials[@provider])

    end


end