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

describe command(". /etc/profile; ls -d $TRANSMART_INSTALL_DIRECTORY/transmart-data") do
  its(:stdout) { should_not match(/ls: cannot access/) }
  its(:exit_status) { should eq 0 }
end

describe command(". /etc/profile; stat $TRANSMART_INSTALL_DIRECTORY/transmart-data/vars") do
  its(:exit_status) { should eq 0 }
end

if os[:family] == 'redhat'
  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'postgres' }
  end

  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'apache ' }
  end

  describe service('postgres') do
    it { should be_running }
  end
end

if os[:family] == 'ubuntu'
  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'postgresql' }
  end

  describe command('ps -ef') do
    its(:stdout) { is_expected.to include 'apache2' }
  end

  describe service('postgresql') do
    it { should be_running }
  end
end

describe command('ps -ef') do
  its(:stdout) { is_expected.to include 'tomcat7' }
end

describe service('tomcat7') do
  it { should be_running }
end

describe service('rserve') do
  it { should be_running }
end

describe 'Postgres port test' do
  it 'is listening on port 5432' do
    expect(port(5432)).to be_listening
  end
end

describe 'Tomcat port test' do
  it 'is listening on port 8080' do
    expect(port(8080)).to be_listening
  end
end

describe command('wget http://localhost:8080/solr') do
  its(:exit_status) { should eq 0 }
end

describe command('wget http://localhost:8080/transmart') do
  its(:exit_status) { should eq 0 }
end
