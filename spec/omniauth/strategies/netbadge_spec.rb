require 'spec_helper'

describe OmniAuth::Strategies::Netbadge do

  include Rack::Test::Methods

  let(:netbadge_provider) { Class.new(OmniAuth::Strategies::Netbadge) }

  before do
    stub_const 'NetbadgeProvider', netbadge_provider
  end

  let(:app) do
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use PubCookie
      use NetbadgeProvider, :name => :netbadge
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["OK"]] }
    }.to_app
  end

  describe 'callback_phase' do
    it 'should raise error when no header set by pub cookie' do
      PubCookie.user nil
      n = OmniAuth::Strategies::Netbadge.new(app)
      expect {n.callback_phase}.to raise_error OmniAuth::Strategies::Netbadge::MissingHeader
    end
  end

  describe 'GET /usersauth/netbadge' do
    before { get "/users/auth/netbadge", nil, { } }

    subject { last_response }

    it { should be_redirect }

    it 'should redirect to the configured URL' do
        expect(subject.headers).to include 'Location' => "/users/auth/netbadge/callback"
    end
  end

  describe 'GET /users/auth/netbadge/callback after Netbadge' do
    before do
      PubCookie.user "user"
      get "/users/auth/netbadge/callback", nil, { }
    end

    context "request.env['omniauth.auth']" do
      subject { last_request.env['omniauth.auth'] }

      it { should be_kind_of Hash }

      it 'identifes the user' do
        expect(subject.uid).to eq "user"
      end

      it 'identifes the provider' do
        expect(subject.provider).to eq :netbadge
      end

    end

  end

end

# A simple Rack middleware to insert a remote user into the request
# environment, simulating what the apache module would do.
class PubCookie

  @@user = nil

  def self.user (username)
    @@user = username
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    env["REMOTE_USER"] = @@user unless @@user.nil?
    @app.call(env)
  end
end