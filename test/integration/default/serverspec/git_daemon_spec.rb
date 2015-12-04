require 'serverspec'

# Required by serverspec
set :backend, :exec

describe command('which git') do
  its(:exit_status) { should eq 0 }
end

describe command('which java') do
  its(:exit_status) { should eq 0 }
end

describe command('which psql') do
  its(:exit_status) { should eq 0 }
end

describe command('which make') do
  its(:exit_status) { should eq 0 }
end

describe command('ls -d transmart-data') do
  its(:stdout) { should match(/transmart-data/) }
end

describe command('stat transmart-data/vars') do
  its(:exit_status) { should eq 0 }
end

if os[:family] == 'redhat'
  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'postgres' }
  end

  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'apache ' }
  end
end

if os[:family] == 'ubuntu'
  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'postgresql' }
  end

  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'apache2' }
  end
end

describe command('ps -ef') do
  its(:stdout) { is_expected.to include 'tomcat7' }
end

describe 'Tomcat Service' do
  it 'is listening on port 8080' do
    expect(port(8080)).to be_listening
  end
end

describe 'Postges Service' do
  it 'is listening on port 5432' do
    expect(port(5432)).to be_listening
  end
end
