require 'spec_helper'
describe 'puppetserver' do
  let(:facts) { { :puppetversion => '3.8.0' } }

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('puppetserver') }
    it { should contain_class('puppetserver::config') }
    it { should contain_package('puppetserver').with_ensure('installed') }
    it {
      should contain_service('puppetserver').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
  end

  describe 'package_name' do
    context "specified as string" do
      let(:params) { { :package_name => 'puppetserver_new' } }
      it { should compile.with_all_deps }
      it { should contain_package('puppetserver_new') }
    end

    context "specified as array" do
      let(:params) { { :package_name => ['pkg1','pkg2'] } }
      it { should compile.with_all_deps }
      it { should contain_package('pkg1') }
      it { should contain_package('pkg2') }
    end
  end

  context "service_name specified" do
    let(:params) { { :service_name => 'puppetserver_alt' } }
    it { should compile.with_all_deps }
    it {
      should contain_service('puppetserver_alt').with({
        'ensure' => 'running',
        'enable' => 'true',
      })
    }
  end

  describe 'service_enable' do
    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :service_enable => value } }
        it { should compile.with_all_deps }
        it { should contain_service('puppetserver').with_enable(true) }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :service_enable => value } }
        it { should compile.with_all_deps }
        it { should contain_service('puppetserver').with_enable(false) }
      end
    end

    context 'with invalid value' do
      let (:params) {{ :service_enable => 'not-a-boolean' }}

      it 'should fail' do
        expect {
          should contain_class('puppetserver')
        }.to raise_error(Puppet::Error, /Unknown type of boolean given/)
      end
    end
  end


end
