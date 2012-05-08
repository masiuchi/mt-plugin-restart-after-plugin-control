package MT::Plugin::RestartAfterPluginControl;
use strict;
use warnings;
use base 'MT::Plugin';

use MT::Touch::NoCache;
use MT::Util;
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
        registry => {
            applications => {
                cms => { methods => { redirect_meta => \&_redirect_meta, }, },
            },
        },
        init_request => \&_init_request,
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
            MT::Touch::NoCache->touch( 0, 'config' );
            return _redirect_meta($app);
        }
    };
}

sub _redirect_meta {
    my ($app) = @_;

    my $redirect = $app->{redirect};
    $app->{redirect} = '';
    return '<meta http-equiv="refresh" content="0.1;url=' . $redirect . '">';
}

sub _init_request {
    my ($app) = @_;

    my $touched = MT::Touch::NoCache->latest_touch( 0, 'config' );
    if ($touched) {
        $touched = MT::Util::ts2epoch( undef, $touched, 1 );
        my $startup = $app->{fcgi_startup_time};
        if ( $startup && $touched > $startup ) {
            my $mode = $app->param('__mode');
            $app->param( '__mode', 'redirect_meta' );
            my $redirect_uri = $app->uri(
                mode => $mode,
                args => $app->{parameters},
            );
            $app->redirect($redirect_uri);
        }
    }
}

1;
__END__
