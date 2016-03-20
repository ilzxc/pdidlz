#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "Touches.hpp"

using namespace ci;
using namespace ci::app;
using namespace std;

class SlabsApp : public App {
  public:
    void setup() override;
#if defined( CINDER_COCOA_TOUCH )
    void touchesBegan( TouchEvent event ) override;
    void touchesMoved( TouchEvent event ) override;
    void touchesEnded( TouchEvent event ) override;
#else
    void mouseDown( MouseEvent event ) override;
    void mouseDrag( MouseEvent event ) override;
    void mouseUp( MouseEvent event ) override;
#endif
    void update() override;
    void draw() override;
    
  private:
    didl::Touches touches;
};

void SlabsApp::setup()
{
    cout << "setup..." << endl;
}

void SlabsApp::update()
{
    cout << "update..." << endl;
}

void SlabsApp::draw()
{
    cout << "draw..." << endl;
    gl::clear( Color( 0, 0, 0 ) );
    for ( auto touch : touches.get() ) {
        gl::color( 1.f, 1.f, 1.f, 0.3f );
        gl::drawSolidCircle( touch.position_previous, 50.0f );
        gl::color( 1.f, 1.f, 1.f, 1.f );
        gl::drawSolidCircle( touch.position, 50.0f );
    }
}

#if defined( CINDER_COCOA_TOUCH )
void SlabsApp::touchesBegan( TouchEvent event )
{
    touches.began( event );
}

void SlabsApp::touchesMoved( TouchEvent event )
{
    touches.moved( event );
}

void SlabsApp::touchesEnded( TouchEvent event )
{
    touches.ended( event );
}

#else
void SlabsApp::mouseDown( MouseEvent event )
{
    
}

void SlabsApp::mouseDrag( MouseEvent event )
{
    
}

void SlabsApp::mouseUp( MouseEvent event )
{
    
}
#endif

CINDER_APP( SlabsApp, RendererGl )
