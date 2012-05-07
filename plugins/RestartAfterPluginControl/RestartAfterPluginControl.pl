package MT::Plugin::RestartAfterPluginControl;
use strict;
use warnings;
use base 'MT::Plugin';

use MT::Touch;
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
            applications =>
                { cms => { methods => { do_nothing => sub {}, }, }, },
        },
        init_request => \&_init_req,
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

sub _init_req {
    my ($app) = @_;

    if ( my $touched = MT::Touch->latest_touch( 0, 'config' ) ) {
        $touched = MT::Util::ts2epoch( undef, $touched, 1 );
        my $startup = $app->{fcgi_startup_time };
        if ( $startup && $touched > $startup ) {
            my $mode = $app->param( '__mode' );
            $app->param( '__mode', 'do_nothing' );
            $app->redirect(
                $app->uri(
                    mode => $mode,
                    args => $app->{parameters},
                ),
                UseMeta => 1,
            );
        }
    }
}

1;
__END__
