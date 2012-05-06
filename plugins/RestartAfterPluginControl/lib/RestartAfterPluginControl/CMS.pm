package RestartAfterPluginControl::CMS;
use strict;
use warnings;

use MT::Touch;
use MT::CMS::Plugin;

sub plugin_control {
    my ( $app ) = @_;

    MT::CMS::Plugin::plugin_control( $app );

    if ( $ENV{FAST_CGI} ) {
        MT::Touch->touch( 0, 'config' );
        $app->{redirect_use_meta} = 1;
    }
}

1;
__END__
