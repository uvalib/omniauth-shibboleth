# Omniauth::Shibboleth

An OmniAuth strategy for UVa's Shibboleth multi-institutional single sign-on.
  Because the heavy-lifting is done by an apache Shibboleth module, this
  strategy is extremely simple, but will only work in a properly configured
   environment.

## Build this Gem locally

    gem build omniauth-shibboleth.gemspec

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-shibboleth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-shibboleth

## Usage

1. Configure apache to enable Shibboleth for a single URL.  Select this URL to
   explicitly not conflict with any other paths within your rails application.
2. Configure your strategy with a :callback_path that points to that Shibboleth
   protected URL
3. Define a find_for_shibboleth method in your user model that builds an
   appropriate user object corresponding to the information from Shibboleth

## Implementation details

Currently, the auth.hash returned by this Strategy only really includes a
provider name and a uid, which is equal the username returned by Shibboleth
or a generic user for the configured affiliation.

The two attributes that are recognized by this implementation are:
eppn
affiliation

If the Shibboleth redirect in apache isn't properly configured, you'll see a
OmniAuth::Strategies::Shibboleth::MissingHeader exception on a stock 500 page.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
