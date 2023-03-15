require 'spec_helper'

describe OmniAuth::Strategies::Shibboleth do

  include Rack::Test::Methods


  let(:app) do
    Rack::Builder.new do |b|
      b.use OmniAuth::Test::PhonySession
      b.use OmniAuth::Strategies::Shibboleth
      OmniAuth.config.request_validation_phase = nil
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
  end

  let(:session) do
    last_request.env['rack.session']
  end

  describe 'callback_phase' do
    it 'should raise error when no headers set by shibboleth' do
      n = OmniAuth::Strategies::Shibboleth.new(app)

      expect {n.callback_phase}.to raise_error OmniAuth::Strategies::Shibboleth::MissingHeader
    end
  end

  describe 'Request Phase: GET /users/auth/shibboleth' do

    it 'should redirect to the configured URL' do
      post "/users/auth/shibboleth"
      expect(last_response).to be_redirect
      expect(last_response.headers).to include 'Location' => "/users/auth/shibboleth/callback"
    end
  end

  describe 'GET /users/auth/shibboleth/callback after Shibboleth with eppn' do
    before do
      get "/users/auth/shibboleth/callback", nil, {'HTTP_EPPN' => 'user@example'}
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "user@example"
      end

      it 'identifes the provider' do
        expect(subject.provider).to eq 'shibboleth'
      end

    end

  end

  describe 'GET /users/auth/shibboleth/callback after Shibboleth with affiliation' do
    before do
      get "/users/auth/shibboleth/callback", nil, { 'HTTP_AFFILIATION' => 'member@virginia.edu'}
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "member@virginia.edu"
      end

      it 'identifes the provider' do
        expect(subject.provider).to eq 'shibboleth'
      end

      it 'passes the affiliation' do
        expect(subject.extra.affiliations).to eq ["member@virginia.edu"]
      end

    end

  end

  describe 'GET /users/auth/shibboleth/callback after Shibboleth with affiliation' do
    before do
      get "/users/auth/shibboleth/callback", nil, { 'HTTP_EPPN' => 'member@virginia.edu', 'HTTP_MEMBER' => 'member@virginia.edu;staff@virginia.edu'}
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "member@virginia.edu"
      end

      it 'passes other memberships' do
        expect(subject.extra.affiliations).to eq ["member@virginia.edu", "staff@virginia.edu"]
      end

    end
  end

end

