/*
  ==============================================================================

    API.h
    Created: 2 Feb 2015 2:36:30am
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#ifndef API_H_INCLUDED
#define API_H_INCLUDED

#include <vector>
#include <string>
#include "APIEnum.h"

typedef struct _osc_message_s t_osc_message_s;
typedef struct _osc_message_u t_osc_message_u;
typedef struct _osc_atom_s t_osc_atom_s;
typedef struct _osc_timetag_ntptime t_osc_timetag;

namespace didl {
namespace odot {
    
class Var;


//==============================================================================
/** Binds C++ variables to an odot API.

    Used in all instances where communication between C++ and odot scripting
    layer is needed. Provides mechanisms for registering C++ memory pointers
    with odot addresses. After the registration stage, allows to generate
    snapshots of state in odot bundles (didl::odot::Var) or to update C++
    values from a bundle (e.g. from a single frame-loop computation requested
    by the end user.
    
    Generally, instances didl::odot::API will be used either to pull values 
    from bundles OR to generate bundles (from internal C++ processes). Due to
    the implementation, function bundleToCpp() and cppToBundle() are not thread
    safe.
    
    TODO: provide subbundle support.

    @see didl::odot::Var, didl::odot::Expr
*/
class API
{
  public:
    ~API();
    
    void addMessage( const std::string& address, std::initializer_list< float* > numeric,       const OSC_TYPES OPTIONS = OSC_NUMERIC );
    void addMessage( const std::string& address, std::initializer_list< int* > numeric,         const OSC_TYPES OPTIONS = OSC_INTEGER );
    void addMessage( const std::string& address, std::initializer_list< double* > numeric,      const OSC_TYPES OPTIONS = OSC_NUMERIC );
    void addMessage( const std::string& address, std::initializer_list< bool* > boolean,        const OSC_TYPES OPTIONS = OSC_BOOLEAN );
    void addMessage( const std::string& address, std::initializer_list< std::string* > strings, const OSC_TYPES OPTIONS = OSC_STRING  );
    void addMessage( const std::string& address, std::initializer_list< long* > numeric,        const OSC_TYPES OPTIONS = OSC_NUMERIC );
    void addMessage( const std::string& address, std::initializer_list< t_osc_timetag* > time,  const OSC_TYPES OPTIONS = OSC_TIMETAG );
    //void subBundle( const std::string& address );
    //void removeAddress( const std::string& address );

    void bundleToCpp( const didl::odot::Var& bundle );
    didl::odot::Var cppToBundle();
    
  private:
    class APIMessage;
    std::vector< APIMessage* > api_messages;
};

} /* namespace odot */
} /* namespace didl */

#endif  // API_H_INCLUDED
