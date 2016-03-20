/*
  ==============================================================================

    Var.cpp
    Created: 14 Jan 2015 11:33:29pm
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#include "Var.h"
#include "osc_error.h"
#include "osc_parser.h"
#include "osc_mem.h"
#include "osc_bundle_u.h"
#include "osc_bundle_iterator_s.h"
#include "osc_message_u.h"
#include <iostream>

namespace didl {
namespace odot {

using namespace std;

Var::Var() noexcept
: var_length( 0L ),
  var_bundle( nullptr )
{
    t_osc_bundle_u* bundle = osc_bundle_u_alloc();
    osc_bundle_u_serialize( bundle, &var_length, &var_bundle );
    osc_bundle_u_free( bundle );
}

Var::Var( const string& text_bundle ) noexcept
: var_length( 0L ),
  var_bundle( nullptr )
{
    setBundle( text_bundle );
}

Var::Var( char* bundle, long bundle_length ) noexcept
{
    t_osc_bundle_s* copy = nullptr;
    t_osc_bundle_s* source = osc_bundle_s_alloc( bundle_length, bundle );
    osc_bundle_s_deepCopy( &copy, source );
    var_bundle = osc_bundle_s_getPtr( copy );
    var_length = osc_bundle_s_getLen( copy );
    osc_bundle_s_free( source );
    osc_bundle_s_free( copy );
}

Var::Var( const Var& other ) noexcept
: var_length( other.var_length )
{
    if ( ( var_length != 0 ) && ( other.var_bundle != nullptr ) )
    {
        t_osc_bundle_s* copy = nullptr;
        t_osc_bundle_s* source = osc_bundle_s_alloc( other.var_length, other.var_bundle );
        osc_bundle_s_deepCopy( &copy, source );
        var_bundle = osc_bundle_s_getPtr( copy );
        var_length = osc_bundle_s_getLen( copy );
        osc_bundle_s_free( source );
        osc_bundle_s_free( copy );
    }
    else
    {
        var_length = 0;
        var_bundle = nullptr;
    }
}

Var::Var( Var&& other ) noexcept
: var_length( other.var_length ),
  var_bundle( other.var_bundle )
{
    other.var_bundle = nullptr;
}
    
    
Var::~Var() noexcept
{
    clear();
}
 
/*
Var& Var::operator=( const Var& rhs )
{
    if ( this == &rhs ) { return *this; }
    
    clear();
    
    if ( ( rhs.var_length != 0 ) && ( rhs.var_bundle != nullptr ) )
    {
        t_osc_bundle_s* copy = nullptr;
        t_osc_bundle_s* source = osc_bundle_s_alloc( rhs.var_length, rhs.var_bundle );
        osc_bundle_s_deepCopy( &copy, source );
        var_bundle = osc_bundle_s_getPtr( copy );
        var_length = osc_bundle_s_getLen( copy );
        osc_bundle_s_free( source );
        osc_bundle_s_free( copy );
    }
    else
    {
        var_length = 0;
        var_bundle = nullptr;
    }
    
    return *this;
}
*/
    
Var& Var::operator=( Var&& rhs )
{
    /// std::cout << "move! (assign)" << std::endl;
    swap( this->var_bundle, rhs.var_bundle );
    this->var_length = rhs.var_length;
    return *this;
}
    

void Var::setBundle( const std::string& text_bundle ) noexcept
{
    t_osc_bundle_u* parsed_bundle = nullptr;
    long parsed_bundle_length = text_bundle.length() + 1;
    t_osc_err error;
    
    clear();

    error = osc_parser_parseString( parsed_bundle_length, text_bundle.c_str(), &parsed_bundle );
    
    if ( error == OSC_ERR_NONE ) {
        osc_bundle_u_serialize( parsed_bundle, &var_length, &var_bundle );
    } else {
        cout << osc_error_string( error ) << endl; /// Push to the console view in the editor in the future...
    }
        
    if ( parsed_bundle != nullptr ) {
        osc_bundle_u_free( parsed_bundle );
    }
}
        
void Var::appendMessage( t_osc_message_u* message )
{
    t_osc_bundle_u* unserialized = nullptr;
    osc_bundle_s_deserialize( var_length, var_bundle, &unserialized );
    osc_bundle_u_addMsg( unserialized, message );
    osc_bundle_u_serialize( unserialized, &var_length, &var_bundle );
}

std::ostream& operator<<( std::ostream& lhs, const Var& rhs )
{
    char* bundle = rhs.getBundle();
    long bundle_length = rhs.getBundleLength();
    long string_length = osc_bundle_s_nformat( nullptr, 0, bundle_length, bundle, 0 );
    char* string = ( char * )osc_mem_alloc( string_length + 1 );
    osc_bundle_s_nformat( string, string_length + 1, bundle_length, bundle, 0 );
    
    if ( string_length == 0 )
    {
        osc_mem_free( string );
        return lhs;
        *string = '\0';
    }
    
    lhs << "+-bundle----------------------------"
        << std::endl << string << std::endl
        << "+-----------------------------------" << std::endl;
    
    if ( string ) {
        osc_mem_free( string );
    }
    return lhs;
}
        
void Var::unionLeft( const Var& other )
{
    performUnion( *this, other );
}

void Var::unionRight( const Var& other )
{
    performUnion( other, *this );
}

        
void Var::clear() noexcept
{
    if ( var_bundle != nullptr )
    {
        free( var_bundle );
        var_bundle = nullptr;
        var_length = 0L;
    }
}
        
void Var::performUnion( const Var& lhs, const Var& rhs )
{
    if ( ( lhs.getBundle() == nullptr ) || ( lhs.getBundleLength() == 0 ) ) return;
    if ( ( rhs.getBundle() == nullptr ) || ( rhs.getBundleLength() == 0 ) ) return;
    
    t_osc_err error;
    char* result = nullptr;
    long result_length = 0L;
    
    error = osc_bundle_s_union( lhs.getBundleLength(), lhs.getBundle(), rhs.getBundleLength(), rhs.getBundle(), &result_length, &result );
    
    if ( error == OSC_ERR_NONE )
    {
        free( var_bundle );
        var_bundle = result;
        var_length = result_length;
    }
    else
    {
        cerr << "Error bundle union: " << osc_error_string( error ) << endl;
    }
}
        
} /* namespace odot */
} /* namespace didl */
