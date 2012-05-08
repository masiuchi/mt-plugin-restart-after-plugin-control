package MT::Touch::NoCache;
use strict;
use warnings;
use base 'MT::Touch';

{
    no warnings 'redefine';
    local *MT::ObectDriver::Driver::CacheWrapper::wrap = sub { $_[1] };
}

1;
__END__
