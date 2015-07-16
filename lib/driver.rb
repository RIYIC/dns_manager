require 'yaml'
require 'active_support/inflector'
require 'drivers/digital_ocean'

module Driver

    ENV_FILENAME = '/home/env'

    def self.get(options)
        
        provider = options[:provider]

        credentials = YAML.load(File.read(ENV_FILENAME)) if File.exists?(ENV_FILENAME)

        raise 'Credentials not found' unless credentials && credentials.has_key?(provider)

        Object.const_get("Driver::#{provider.camelize}").
            new(credentials[provider])

    end


end