require 'spec_helper'

describe OmniAuth::Strategies::Shibboleth do

  include Rack::Test::Methods

  let(:shibboleth_provider) { Class.new(OmniAuth::Strategies::Shibboleth) }

  before do
    stub_const 'ShibbolethProvider', shibboleth_provider
  end

  let(:app) do
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use Shibboleth
      use ShibbolethProvider, :name => :shibboleth
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
    }.to_app
  end

  describe 'callback_phase' do
    it 'should raise error when no headers set by shibboleth' do
      Shibboleth.eppn nil
      Shibboleth.affiliation nil
      n = OmniAuth::Strategies::Shibboleth.new(app)
      expect {n.callback_phase}.to raise_error OmniAuth::Strategies::Shibboleth::MissingHeader
    end
  end

  describe 'GET /usersauth/shibboleth' do
    before { get "/users/auth/shibboleth", nil, { } }

    subject { last_response }

    it { should be_redirect }

    it 'should redirect to the configured URL' do
        expect(subject.headers).to include 'Location' => "/users/auth/shibboleth/callback"
    end
  end

  describe 'GET /users/auth/shibboleth/callback after Shibboleth with eppn' do
    before do
      Shibboleth.eppn "user"
      get "/users/auth/shibboleth/callback", nil, { }
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "user"
      end

      it 'identifes the provider' do
        expect(subject.provider).to eq :shibboleth
      end

    end

  end

  describe 'GET /users/auth/shibboleth/callback after Shibboleth with affiliation' do
    before do
      Shibboleth.eppn nil
      Shibboleth.affiliation "member@virginia.edu"
      get "/users/auth/shibboleth/callback", nil, { }
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "User from virginia.edu"
      end

      it 'identifes the provider' do
        expect(subject.provider).to eq :shibboleth
      end
      
      it 'passes the affiliation' do 
        expect(subject.extra.affiliations).to eq ["member@virginia.edu"]
      end

    end

  end

end

# A simple Rack middleware to optionally insert an eppn and affiliation
# into the request environment, simulating what the apache Shibboleth
# module would do.
class Shibboleth

  @@eppn = nil

  @@affiliation = nil

  def self.eppn (username)
    @@eppn = username
  end

  def self.affiliation (affiliation)
    @@affiliation = affiliation
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    env["eppn"] = @@eppn unless @@eppn.nil?
    env["affiliation"] = @@affiliation unless @@affiliation.nil?
    @app.call(env)
  end
end
