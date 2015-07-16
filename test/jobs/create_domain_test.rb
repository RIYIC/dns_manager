require 'test_helper'

class CreateDomainTest < ActiveJob::TestCase

    test_domain = 'example.com'


    test 'domain registration' do
        domain = DropletKit::Domain.new(
            name: test_domain,
            ip_address: '95.85.33.24'
        )

        response = api_fixture('digital_ocean/domains/create')

        domain_as_json = DropletKit::DomainMapping.representation_for(:create, domain)

        # domains.create
        stub_do_api('/v2/domains', :post).
            with(body: domain_as_json).to_return(body: response, status: 201)


        # records.all
        records = api_fixture('digital_ocean/domains/default_records')

        stub_do_api("/v2/domains/#{test_domain}/records",:get).
            to_return(:status => 200, :body => records)

        # record.delete
        stub_do_api("/v2/domains/#{test_domain}/records/15", :delete).
            to_return(:status => 204)

        # recordNS = DropletKit::DomainRecord.new(
        #     type: 'NS',
        #     name: '@',
        #     data: /riyic.com/,
        # )
        #
        # recordNS_json = DropletKit::DomainRecordMapping.representation_for(
        #     :create, recordNS
        # )

        # record.create (para os NS)
        response_NS = api_fixture('digital_ocean/domain_records/create_A')

        stub_do_api("/v2/domains/#{test_domain}/records", :post).
            with(body: hash_including({
                                          type: 'NS',
                                          name: '@'
                                      })).to_return(status: 201, body: response_NS)



        assert_nothing_raised{
            CreateDomain.perform_now(name: test_domain, user_id: 1 )
        }

        assert_not Domain.find_by_name(test_domain).nil?, test_domain

        assert Domain.find_by_name(test_domain).records.size == 3

        # esto deberia ir en outro test
        # pero hai que ter creado o dominio
        response_A = api_fixture('digital_ocean/domain_records/create_A')
        response_CNAME = api_fixture('digital_ocean/domain_records/create_CNAME')

        record1 = DropletKit::DomainRecord.new(
            type: 'A',
            name: 'test',
            data: '127.0.0.1'
        )

        record1_json = DropletKit::DomainRecordMapping.representation_for(
            :create, record1
        )

        record2 = DropletKit::DomainRecord.new(
            type: 'CNAME',
            name: 'testcname',
            data: 'test'
        )

        record2_json = DropletKit::DomainRecordMapping.representation_for(
            :create, record2
        )


        stub_do_api("/v2/domains/#{test_domain}/records", :post).
            with(body: record1_json).to_return(body:response_A, status: 201)

        stub_do_api("/v2/domains/#{test_domain}/records", :post).
            with(body: record2_json).to_return(body:response_CNAME, status: 201)


        assert_nothing_raised{
            CreateZoneRecord.perform_now(
                                domain: test_domain,
                                name: 'test',
                                zone_type: 'A',
                                data: '127.0.0.1',
            )
        }

        assert_nothing_raised{
            CreateZoneRecord.perform_now(
                domain: test_domain,
                name: 'testcname',
                zone_type: 'CNAME',
                data: 'test',
            )
        }
    end

    # test 'domain update records' do
    #
    #     assert_nothing_raised(){
    #         UpdateZoneRecord.perform_now()
    #     }
    # end
    #
    #
    #
    #
    # test 'domain remove records' do
    #
    #     assert_nothing_raised(){
    #         RemoveZoneRecord.perform_now()
    #     }
    # end
    #
    # test 'domain remove' do
    #
    #     assert_nothing_raised(){
    #         RemoveDomain.perform_now(name: test_domain)
    #     }
    #
    #     assert_not Domain.find_by_name(test_domain)
    #
    # end

end