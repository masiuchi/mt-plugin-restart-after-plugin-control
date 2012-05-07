package MT::Plugin::RestartAfterPluginControl;
use strict;
use warnings;
use base 'MT::Plugin';

use MT::Touch;
use MT::CMS::Plugin;

our $VERSION = '0.03';
our $NAME = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new(
    {   name        => $NAME,
        id          => lc $NAME,
        key         => lc $NAME,
        version     => $VERSION,
        author_name => 'masiuchi',
        author_link => 'https://github.com/masiuchi',
        plugin_link =>
            'https://github.com/masiuchi/mt-plugin-restart-after-plugin-control',
        description =>
            'Restart FastCGI process after changing plugin status.',
    }
);
MT->add_plugin($plugin);

{
    my $orig = \&MT::CMS::Plugin::plugin_control;

    no warnings 'redefine';
    *MT::CMS::Plugin::plugin_control = sub {
        my ($app) = @_;

        $orig->($app);

        if ( $ENV{FAST_CGI} && !$app->{_errstr} && $app->{redirect} ) {
            MT::Touch->touch( 0, 'config' );
            $app->{redirect_use_meta} = 1;
        }
    };
}

1;
__END__
