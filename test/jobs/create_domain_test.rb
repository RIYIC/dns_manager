require 'test_helper'

class CreateDomainTest < ActiveJob::TestCase

    test_domain = ''

    for i in 1..10 do

        test_domain = generate_random_string() + '.com'

        break unless Domain.find_by_name(test_domain)


    end

    puts "Probando #{test_domain}"



    test 'domain registration' do

        assert_nothing_raised(){
            CreateDomain.perform_now(name: test_domain, user_id: 1 )
        }

        d = Domain.find_by_name(test_domain)
        assert_not Domain.find_by_name(test_domain).nil?, test_domain
        assert Domain.find_by_name(test_domain).records.size == 3

    end

    test 'domain add records' do

        assert_nothing_raised(){
            CreateZoneRecord.perform_now(
                                domain: test_domain,
                                name: 'test',
                                zone_type: 'A',
                                data: '127.0.0.1',
            )
        }

        assert_nothing_raised(){
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