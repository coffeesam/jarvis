require 'spec_helper'
require 'rails_helper'

describe Ldap do
  describe "#new" do
    context "when initializing" do
      context 'with username and password' do
        it 'returns a Ldap instance' do
          expect(Ldap.new('test', 'password')).to be_an_instance_of Ldap
        end

        it 'returns a Ldap instance with the correct attributes' do
          ldap = Ldap.new('test', 'password')
          expect(ldap.username).to eq 'test'
          expect(ldap.password).to eq 'password'
        end
      end
    end
  end

  shared_examples_for "a bad authenticated session" do
    before do
      allow_any_instance_of(Net::LDAP).to receive(:bind).and_return(false)
    end
    it 'returns a nil object' do
      ldap   = Ldap.new('test', 'bad_password')
      expect(ldap.connect).to be_falsy
      expect(ldap.authenticate).to be_nil
    end
  end

  describe "#authenticate" do
    context 'when connecting' do
      it 'attempts to create a LDAP connection' do
          expect_any_instance_of(Net::LDAP).to receive(:bind).and_return(true)
          expect_any_instance_of(Ldap).to receive(:search).and_return([])
          expect(Net::LDAP).to receive(:new).with(
            :host => 'testhost',
            :port => 389,
            :auth => {
              :method => :simple,
              :username => "test@example.com",
              :password => 'password'
            }
          ).and_call_original
          ldap = Ldap.new("test", "password")
          ldap.authenticate
      end
    end

    context 'when authenticating' do
      context 'with a set of correct username and password' do
        before do
          expect_any_instance_of(Net::LDAP).to receive(:bind).and_return(true)
          ldap_user = [{
            :sAMAccountName => ['test'],
            :mail => ['test@example.com'],
            :objectcategory => "CN=Person"
          }]
          expect_any_instance_of(Net::LDAP).
            to receive(:search).at_least(:once).and_return(ldap_user)
        end

        it 'returns a user object with the username and email filled up' do
          ldap = Ldap.new("test", "password")
          user = ldap.authenticate
          expect(user).to be_instance_of(User)
          expect(user.username).to eq 'test'
          expect(user.email).to eq 'test@example.com'
        end

        it 'searches LDAP with the username that was passed in' do
          expect_any_instance_of(Ldap).
            to receive(:search).with('sample').and_call_original
          ldap = Ldap.new('sample', "password")
          ldap.authenticate
        end
      end
    end

    context 'with a set of incorrect username and password' do
      it_behaves_like "a bad authenticated session"
    end

    context 'with bad connection' do
      it_behaves_like "a bad authenticated session"

      it 'throws an error' do
        LDAP_CONFIG['host'] = 'badhostname'
        ldap = Ldap.new('test', 'password')
        expect{ ldap.authenticate }.to raise_error(Net::LDAP::LdapError)
      end
    end
  end

end
