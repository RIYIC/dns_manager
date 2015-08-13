class RemoveDomain < ActiveJob::Base

    queue_as :bajas

    def perform(*args)

        driver = Driver.get(provider: Rails.configuration.x.provider)

        driver.remove_domain(args)

        Domain.find(name: args[:name]).destroy!


    end


end
