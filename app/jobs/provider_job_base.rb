require 'driver'

class ProviderJobBase < ActiveJob::Base

    queue_as :normal


    def get_driver(args={})

        provider = args[:provider] || Rails.configuration.x.default_provider

        Driver.get(provider: provider)

    end

    def get_provider(args={})
        provider = args[:provider] || Rails.configuration.x.default_provider

        Provider.find_by_slug!(provider)

    end


end
