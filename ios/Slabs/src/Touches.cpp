//
//  Touches.cpp
//  Slabs
//
//  Created by Ilya Rostovtsev on 2/13/16.
//
//

#include "Touches.hpp"

void didl::Touches::began( const ci::app::TouchEvent& event )
{
    for ( const auto& ci_touch : event.getTouches() ) {
        touches.push_back( didl::Touch{ ci_touch } );
    }
}

void didl::Touches::moved( const ci::app::TouchEvent& event )
{
    for ( const auto& ci_touch : event.getTouches() ) {
        for ( auto& di_touch : touches ) {
            di_touch.update( ci_touch );
        }
    }
}

void didl::Touches::ended( const ci::app::TouchEvent& event )
{
    for ( const auto& ci_touch : event.getTouches() ) {
        touches.erase( std::remove_if( touches.begin(), touches.end(),
                                       [=]( didl::Touch t ) { return ( t.state == ci_touch.getId() ); } ),
                       touches.end() );
    }
}