/*
  ==============================================================================

    Var.h
    Created: 14 Jan 2015 11:33:29pm
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#ifndef VAR_H_INCLUDED
#define VAR_H_INCLUDED

#include <string>
#include <ostream>

typedef struct _osc_message_u t_osc_message_u;

namespace didl {
namespace odot {
  
//==============================================================================
/** A data structure for an odot bundle - an immutable dictionary-like container
    of name-value bindings.

    @see didl::odot::Expr, didl::odot::API
*/
class Var
{
  public:
    Var() noexcept;
    Var( const std::string& text_bundle ) noexcept;
    Var( char* bundle, long bundle_length ) noexcept;
    Var( const Var& other ) noexcept; // ought to delete
    Var( Var&& other ) noexcept;
    ~Var() noexcept;
    
    // Var& operator=( const Var& rhs ); // out to delete
    Var& operator=( Var&& rhs );
    friend std::ostream& operator<<( std::ostream& lhs, const Var& rhs );
    
    char* getBundle() const noexcept       { return var_bundle; }
    long  getBundleLength() const noexcept { return var_length; }
    void  setBundle( const std::string& text_bundle ) noexcept;
    void  appendMessage( t_osc_message_u* message );
    
    void  unionLeft( const Var& other );
    void  unionRight( const Var& other );
    
  private:
    long  var_length;
    char* var_bundle;
    
    void clear() noexcept;
    void performUnion( const Var& lhs, const Var& rhs );
};
    
} /* namespace odot */
} /* namespace didl */



#endif  // VAR_H_INCLUDED
