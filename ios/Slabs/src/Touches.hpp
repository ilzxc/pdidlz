//
//  Touches.hpp
//  Slabs
//
//  Created by Ilya Rostovtsev on 2/13/16.
//
//

#ifndef Touches_hpp
#define Touches_hpp

#include "cinder/app/TouchEvent.h"

using namespace std;

namespace didl {
    
    struct Touch {
        ci::vec2 position;
        ci::vec2 position_previous;
        ci::vec2 position_started;
        uint32_t id;
        uint32_t state;
        double time_current;
        double time_started;
        
        Touch( ci::app::TouchEvent::Touch touch )
        : position( touch.getPos() ),
          position_previous( touch.getPrevPos() ),
          position_started( touch.getPos() ),
          id( touch.getId() ),
          state( 0 ),
          time_current( touch.getTime() ),
          time_started( touch.getTime() )
        { }
        
        void update( ci::app::TouchEvent::Touch touch ) {
            if ( touch.getId() != id ) return;
            position = touch.getPos();
            position_previous = touch.getPrevPos();
            state = 1;
            time_current = touch.getTime();
        }
    };

    class Touches {
      public:
        Touches() { }
        ~Touches() { }
        
        void began( const ci::app::TouchEvent& event );
        void moved( const ci::app::TouchEvent& event );
        void ended( const ci::app::TouchEvent& event );
        inline const std::vector< didl::Touch >& get() const { return touches; }
        
      private:
        std::vector< didl::Touch > touches;
    };
    
    inline std::ostream& operator<<( std::ostream &out, const didl::Touch &touch )
    {
        out << "- touch ----------\n";
        out << " /id : " << touch.id << "\n";
        out << " /position: " << touch.position << "\n";
        out << " /position/previous : " << touch.position_previous << "\n";
        out << " /position/started : " << touch.position_started << "\n";
        out << " /state : " << touch.state << "\n";
        out << " /time/current : " << touch.time_current << "\n";
        out << " /time/started : " << touch.time_started << "\n";
        out << "------------------\n";
        return out;
    }
    
    inline std::ostream& operator<<( std::ostream &out, const didl::Touches &touches )
    {
        out << "[\n";
        for ( auto t : touches.get() ) {
            out << "    " << t << std::endl;
        }
        out << "]\n";
        return out;
    }
}

#endif /* Touches_hpp */
