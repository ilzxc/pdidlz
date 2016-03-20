/*
  ==============================================================================

    Net.cpp
    Created: 8 Feb 2015 6:09:37pm
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#include "Net.h"
#include "Var.h"
#include "osc_error.h"

namespace didl { namespace net {

bool Socket::send( const Address& destination, const didl::odot::Var& bundle )
{
    return Send( destination, bundle.getBundle(), bundle.getBundleLength() );
}

didl::odot::Var Socket::receive()
{
    Address sender;
    char buffer[ 65507 ]; // maximum udp packet size under IPv4 is 65507 - this is for testing only
    long bytes_read = Receive( sender, buffer, sizeof( buffer ) );
    if ( bytes_read ) {
        t_osc_err error = osc_error_bundleSanityCheck( static_cast< int >( bytes_read ), buffer );
        if ( error == OSC_ERR_NONE ) {
            char* bundle = new char[ bytes_read ];
            memcpy( bundle, buffer, bytes_read );
            return didl::odot::Var( bundle, bytes_read );
        }
    }
    return didl::odot::Var();
}

} /* namespace net */ } /* namespace didl */