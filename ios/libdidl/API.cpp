/*
  ==============================================================================

    API.cpp
    Created: 2 Feb 2015 2:36:30am
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#include "API.h"
#include "Var.h"
#include "osc_bundle_iterator_s.h"
#include "osc_message_s.h"
#include "osc_bundle_u.h"
#include "osc_mem.h"
#include "osc_timetag.h"
#include "osc.h"

namespace didl {
namespace odot {
    
using namespace std;

class API::APIMessage
{
  public:
    APIMessage()  { }
    ~APIMessage()
    {
        for ( auto t : types ) {
            delete t;
        }
    }
    
    void registerAddress( const std::string& address_ ) { address = std::string( address_ ); }
    std::string getAddress() const { return address; }
    void addArgument( const OSC_TYPES osc_type, const CPP_TYPES cpp_type, void* data );
    void swallowMessage( t_osc_message_s* message );
    t_osc_message_u* generateMessage();
    
  private:
    class APIData
    {
      public:
        APIData(): osc_type( OSC_NUMERIC ), cpp_type( CPP_FLOAT ) { }
        APIData( const OSC_TYPES osc_type, const CPP_TYPES cpp_type, void* data );
        ~APIData();
        
        void swallowArgument( t_osc_message_s* message, const int index );
        t_osc_message_u* generateArgument( t_osc_message_u* message ) const;
        
      private:
        int osc_type;
        int cpp_type;
        void* data;
        
        bool IS_NUMERIC( const char tt ) const {
            return ( tt == 'f' || tt == 'd' || tt == 'i' || tt == 'I' || tt == 'h' || tt == 'H' || tt == 'u' || tt == 'U' || tt == 'c' || tt == 'C' );
        }
        bool IS_FLOAT( const char tt ) const {
            return ( tt == 'f' || tt == 'd' );
        }
        bool IS_INT( const char tt ) const {
            return ( tt == 'i' || tt == 'I' || tt == 'h' || tt == 'H' || tt == 'u' || tt == 'U' || tt == 'c' || tt == 'C' );
        }
        bool IS_BOOL( const char tt ) const {
            return ( tt == 'T' || tt == 'F' );
        }
        bool IS_STRING( const char tt ) const {
            return ( tt == 's' );
        }
        bool IS_TIMETAG( const char tt ) const {
            return ( tt == OSC_TIMETAG_TYPETAG );
        }
        
        void updateFloat  ( t_osc_atom_s* atom, const char typetag );
        void updateInt    ( t_osc_atom_s* atom, const char typetag );
        void updateLong   ( t_osc_atom_s* atom, const char typetag );
        void updateDouble ( t_osc_atom_s* atom, const char typetag );
        void updateString ( t_osc_atom_s* atom, const char typetag );
        void updateBool   ( t_osc_atom_s* atom, const char typetag );
        void updateTimeTag( t_osc_atom_s* atom, const char typetag );
    };
    std::string address;
    std::vector< APIData* > types;
};

API::~API()
{
    for ( auto* m : api_messages ) {
        delete m;
    }
}

void API::addMessage( const std::string &address, std::initializer_list< float* > numeric, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : numeric ) {
        to_add->addArgument( OPTIONS, CPP_FLOAT, n );
    }
    api_messages.push_back( to_add );
}

void API::addMessage( const std::string& address, std::initializer_list< int* > numeric, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : numeric ) {
        to_add->addArgument( OPTIONS, CPP_INT, n );
    }
    api_messages.push_back( to_add );
}

void API::addMessage( const std::string& address, std::initializer_list< double* > numeric, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : numeric ) {
        to_add->addArgument( OPTIONS, CPP_DOUBLE, n );
    }
    api_messages.push_back( to_add );
}

void API::addMessage( const std::string& address, std::initializer_list< bool* > boolean, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : boolean ) {
        to_add->addArgument( OPTIONS, CPP_BOOL, n );
    }
    api_messages.push_back( to_add );
}

void API::addMessage( const std::string& address, std::initializer_list< std::string* > strings, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : strings ) {
        to_add->addArgument( OPTIONS, CPP_STRING, n );
    }
    api_messages.push_back( to_add );
}
    
void API::addMessage( const std::string& address, std::initializer_list< long* > numeric, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* n : numeric ) {
        to_add->addArgument( OPTIONS, CPP_LONG, n );
    }
    api_messages.push_back( to_add );
}
    
    
void API::addMessage( const std::string& address, std::initializer_list< t_osc_timetag* > time, const OSC_TYPES OPTIONS )
{
    APIMessage* to_add = new APIMessage();
    to_add->registerAddress( address );
    for ( auto* tt : time ) {
        to_add->addArgument( OPTIONS, CPP_TIMETAG, tt );
    }
    api_messages.push_back( to_add );
}

void API::bundleToCpp( const didl::odot::Var &bundle )
{
    t_osc_bundle_iterator_s* iterator = osc_bundle_iterator_s_getIterator( bundle.getBundleLength(), bundle.getBundle() );
    while ( osc_bundle_iterator_s_hasNext( iterator ) )
    {
        t_osc_message_s* message = osc_bundle_iterator_s_next( iterator );  // iterate over messages in an incoming bundle
        string current_address = osc_message_s_getAddress( message );       // look at the address
        for ( auto& api_message : api_messages ) {                          // for each of the api messages
            if ( current_address == api_message->getAddress() ) {           // if addresses match...
                api_message->swallowMessage( message );                     // consume the message
            }
        }
    }
    osc_bundle_iterator_s_destroyIterator( iterator );
}

odot::Var API::cppToBundle()
{
    t_osc_bundle_u* bundle = osc_bundle_u_alloc();
    for ( auto& m : api_messages ) {
        osc_bundle_u_addMsg( bundle, m->generateMessage() );
    }
    char* ptr = nullptr;
    long  len = 0L;
    osc_bundle_u_serialize( bundle, &len, &ptr );
    osc_bundle_u_free( bundle );
    return Var( ptr, len );
}

void API::APIMessage::addArgument( const OSC_TYPES osc_type, const CPP_TYPES cpp_type, void* data )
{
    types.push_back( new APIData( osc_type, cpp_type, data ) );
}

void API::APIMessage::swallowMessage( t_osc_message_s* message )
{
    int numArgs = osc_message_s_getArgCount( message );
    int counter = 0;
    
    for ( auto& type : types ) {
        type->swallowArgument( message, counter );
        ++counter;
        if ( counter >= numArgs ) break;
    }
}

t_osc_message_u* API::APIMessage::generateMessage()
{
    t_osc_message_u* message = osc_message_u_allocWithAddress( address.c_str() );
    
    for ( auto& arg : types ) {
        message = arg->generateArgument( message );
    }
    
    return message;
}

API::APIMessage::APIData::APIData( const OSC_TYPES osc_type, const CPP_TYPES cpp_type, void* data )
: osc_type( osc_type ),
cpp_type( cpp_type ),
data( data )
{
}

API::APIMessage::APIData::~APIData()
{
}

void API::APIMessage::APIData::swallowArgument( t_osc_message_s* message, const int index )
{
    char typetag = osc_message_s_getTypetag( message, index );
    bool right_osc_type;
    
    switch ( osc_type ) {
        case OSC_NUMERIC :
            right_osc_type = IS_NUMERIC( typetag );
            break;
        case OSC_TIMETAG :
            right_osc_type = IS_TIMETAG( typetag );
            break;
        case OSC_FLOAT   :
            right_osc_type = IS_FLOAT( typetag );
            break;
        case OSC_INTEGER :
            right_osc_type = IS_INT( typetag );
            break;
        case OSC_BOOLEAN :
            right_osc_type = IS_BOOL( typetag );
            break;
        case OSC_STRING  :
            right_osc_type = IS_STRING( typetag );
            break;
        default: right_osc_type = false;
    }
    
    if ( right_osc_type ) {
        t_osc_atom_s* atom = nullptr;
        osc_message_s_getArg( message, index, &atom );
        
        switch ( cpp_type ) {
            case CPP_FLOAT  :
                updateFloat( atom , typetag );
                break;
            case CPP_INT    :
                updateInt( atom , typetag );
                break;
            case CPP_LONG :
                updateLong( atom, typetag );
                break;
            case CPP_DOUBLE :
                updateDouble( atom , typetag );
                break;
            case CPP_TIMETAG :
                updateTimeTag( atom, typetag );
                break;
            case CPP_BOOL   :
                updateBool( atom , typetag );
                break;
            case CPP_STRING :
                updateString( atom , typetag );
                break;
        }
        
        osc_atom_s_free( atom );
    }
}

t_osc_message_u* API::APIMessage::APIData::generateArgument( t_osc_message_u* message ) const
{
    switch ( cpp_type ) {
        case CPP_FLOAT  :
            osc_message_u_appendFloat( message, *static_cast< float* >( data ) );
            break;
        case CPP_INT    :
            osc_message_u_appendInt32( message, *static_cast< int* >( data ) );
            break;
        case CPP_DOUBLE :
            osc_message_u_appendDouble( message, *static_cast< double* >( data ) );
            break;
        case CPP_LONG :
            osc_message_u_appendInt64( message, *static_cast< long* >( data ) );
        case CPP_BOOL   :
            if ( *static_cast< bool* >( data ) ) {
                osc_message_u_appendTrue( message );
            } else {
                osc_message_u_appendFalse( message );
            }
            break;
        case CPP_STRING :
            osc_message_u_appendString( message, static_cast< string* >( data )->c_str() );
            break;
        case CPP_TIMETAG :
            osc_message_u_appendTimetag( message, *static_cast< t_osc_timetag* >( data ) );
        default : return message;
    }
    return message;
}

void API::APIMessage::APIData::updateFloat( t_osc_atom_s* atom, const char typetag )
{
    float result;
    result = osc_atom_s_getFloat( atom );
    float* better_ptr = static_cast< float* >( data );
    *better_ptr = result;
}

void API::APIMessage::APIData::updateInt( t_osc_atom_s* atom, const char typetag )
{
    int result;
    result = osc_atom_s_getInt( atom );
    int* better_ptr = static_cast< int* >( data );
    *better_ptr = result;
}
    
void API::APIMessage::APIData::updateLong( t_osc_atom_s* atom, const char typetag )
{
    long result;
    result = osc_atom_s_getInt64( atom );
    long* better_ptr = static_cast< long* >( data );
    *better_ptr = result;
}

void API::APIMessage::APIData::updateDouble( t_osc_atom_s* atom, const char typetag )
{
    double result;
    result = osc_atom_s_getDouble( atom );
    double* better_ptr = static_cast< double* >( data );
    *better_ptr = result;
}

void API::APIMessage::APIData::updateString( t_osc_atom_s* atom, const char typetag )
{
    std::string result;
    if ( typetag == 's' ) {
        char* osc_string = NULL;
        osc_atom_s_getString( atom, osc_atom_s_getStringLen( atom ), &osc_string );
        result = osc_string;
        osc_mem_free( osc_string );
    }
    std::string* better_ptr = static_cast< std::string* >( data );
    *better_ptr = result;
}

void API::APIMessage::APIData::updateTimeTag( t_osc_atom_s* atom, const char typetag )
{
    t_osc_timetag result;
    osc_atom_s_getTimetag( atom );
    t_osc_timetag* better_ptr = static_cast< t_osc_timetag* >( data );
    *better_ptr = result;
}
    
 
void API::APIMessage::APIData::updateBool( t_osc_atom_s* atom, const char typetag )
{
    bool result;
    switch ( typetag ) {
        case 'T' : result = true;  break;
        case 'F' : result = false; break;
        default  : return;
    }
    bool* better_ptr = static_cast< bool* >( data );
    *better_ptr = result;
}

} /* namespace odot */
} /* namespace didl */