require 'spec_helper'
describe 'puppetserver::config' do
  let(:facts) { { :puppetversion => '3.8.0' } }

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('puppetserver::config') }
    it { should have_file_line_resource_count(2) }
    it { should have_puppetserver__config__hocon_resource_count(0) }
    it do
      should contain_file_line('ca.certificate-authority-service').with({
        'line'  => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'path'  => '/etc/puppetserver/bootstrap.cfg',
      })
    end
    it do
      should contain_file_line('ca.certificate-authority-disabled-service').with({
        'line'  => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'path'  => '/etc/puppetserver/bootstrap.cfg',
      })
    end
  end

  context 'with bootstrap_settings set to valid hash' do
    let(:params) { { :bootstrap_settings => { 'rspec' => { 'line'  => 'testing242', 'match' => 'testing'  } } } }

    it { should have_file_line_resource_count(3) }
    it do
      should contain_file_line('rspec').with({
        'line'  => 'testing242',
        'match' => 'testing',
        'path'  => '/etc/puppetserver/bootstrap.cfg',
      })
    end
  end

  context 'with puppetserver_settings set to valid hash' do
    let(:params) { { :puppetserver_settings => { 'jruby-puppet.max-active-instances' => { 'value'  => '6' } } } }

    it { should have_puppetserver__config__hocon_resource_count(1) }
    it do
      should contain_puppetserver__config__hocon('jruby-puppet.max-active-instances').with({
        'ensure' => 'present',
        'path'   => '/etc/puppetserver/conf.d/puppetserver.conf',
        'value'  => '6',
      })
    end
  end

  context 'with webserver_settings set to valid hash' do
    let(:params) { { :webserver_settings => { 'rspec' => { 'value'  => '242' } } } }

    it { should have_puppetserver__config__hocon_resource_count(1) }
    it do
      should contain_puppetserver__config__hocon('rspec').with({
        'ensure' => 'present',
        'path'   => '/etc/puppetserver/conf.d/webserver.conf',
        'value'  => '242',
      })
    end
  end

  describe 'enable_ca' do
    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :enable_ca => value } }
        it { should compile.with_all_deps }
        it {
          should contain_file_line('ca.certificate-authority-service').with({
            'line' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
          })
        }
        it {
          should contain_file_line('ca.certificate-authority-disabled-service').with({
            'line' => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
          })
        }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :enable_ca => value } }
        it { should compile.with_all_deps }
        it {
          should contain_file_line('ca.certificate-authority-service').with({
            'line' => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
          })
        }
        it {
          should contain_file_line('ca.certificate-authority-disabled-service').with({
            'line' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
          })
        }
      end
    end

    context 'with invalid value' do
      let (:params) {{ :enable_ca => 'not-a-boolean' }}

      it 'should fail' do
        expect {
          should contain_class('puppetserver::config')
        }.to raise_error(Puppet::Error, /Unknown type of boolean given/)
      end
    end
  end

  describe 'with hiera providing data from multiple levels' do
    let(:facts) do
      {
        :fqdn          => 'all_settings',
        :test          => 'all_settings',
        :puppetversion => '3.8.0',
      }
    end

    context 'with defaults for all parameters' do
      it { should have_file_line_resource_count(3) }
      it { should contain_file_line('ca.certificate-authority-service') }
      it { should contain_file_line('ca.certificate-authority-disabled-service') }
      it { should contain_file_line('bootstrap_settings_from_hiera_fqdn') }

      it { should have_puppetserver__config__hocon_resource_count(2) }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_fqdn') }
    end

    context 'with bootstrap_settings_hiera_merge set to valid <true>' do
      let(:params) { { :bootstrap_settings_hiera_merge => true } }
      it { should have_file_line_resource_count(4) }
      it { should contain_file_line('ca.certificate-authority-service') }
      it { should contain_file_line('ca.certificate-authority-disabled-service') }
      it { should contain_file_line('bootstrap_settings_from_hiera_fqdn') }
      it { should contain_file_line('bootstrap_settings_from_hiera_test') }
    end

    context 'with puppetserver_settings_hiera_merge set to valid <true>' do
      let(:params) { { :puppetserver_settings_hiera_merge => true } }

      it { should have_puppetserver__config__hocon_resource_count(3) }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('puppetserver_settings_from_hiera_test') }
    end

    context 'with webserver_settings_hiera_merge set to valid <true>' do
      let(:params) { { :webserver_settings_hiera_merge => true } }

      it { should have_puppetserver__config__hocon_resource_count(3) }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_fqdn') }
      it { should contain_puppetserver__config__hocon('webserver_settings_from_hiera_test') }
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        :puppetversion => '3.8.0'
      }
    end
    let(:mandatory_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'boolean/stringified' => {
        :name    => %w(bootstrap_settings_hiera_merge puppetserver_settings_hiera_merge webserver_settings_hiera_merge),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'is not a boolean',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'

end
