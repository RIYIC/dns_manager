class DomainsController < ApplicationController

    def index
    end

    def show
    end

    def create
        CreateDomain.perform_later(params)
    end

    def destroy
    end

end
