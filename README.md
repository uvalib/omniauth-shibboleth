# Omniauth::Netbadge

An OmniAuth strategy for UVa's Netbadge single sign-on.
  The local philosophy is not to implement the pubcookie protocol for each
  application but instead to use a single standard implementation (an apache
  module) to do the heavy lifting.  Therefore this strategy is extremely
  simple, but will only work in a properly configured environment.

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-netbadge'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-netbadge

## Usage

1. Configure apache to enable Netbadge for a single URL.  Select this URL to
   explicitly not conflict with any other paths within your rails application.
2. Configure your strategy with a :callback_path that points to that Netbadge
   protected URL
3. Define a find_for_netbadge method in your user model that builds an
   appropriate user object corresponding to the information from Netbadge

## Implementation details

Currently, the auth.hash returned by this Strategy only really includes a
provider name and a uid, which is equal the username returned by netbadge.

If the pubcookie redirect in apache isn't properly configured, you'll see a
OmniAuth::Strategies::Netbadge::MissingHeader exception on a stock 500 page.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
