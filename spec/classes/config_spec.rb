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
end
