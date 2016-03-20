/*
 ==============================================================================
 
 Expr.h
 Created: 14 Jan 2015 11:33:00pm
 Author:  Ilya Rostovtsev
 
 ==============================================================================
 */

#ifndef EXPR_H_INCLUDED
#define EXPR_H_INCLUDED

#include <string>

typedef struct _osc_expr t_osc_expr;

namespace didl {
namespace odot {

class Var;

//==============================================================================
/** Provides support for the odot expression language.

    Parses expression strings, and evaluates expressions using instances
    of didl::odot::Var as the context of computation.

    @see didl::odot::Var, didl::odot::API
*/    
class Expr
{
  public:
    Expr();
    Expr( const Expr& other );
    ~Expr();
    
    Expr& operator=( const Expr& rhs );
        
    void replaceExpression( const std::string& expression );
    Var execute( const Var& var );
    
    const std::string& getString() const { return expr_string; }
    
  private:
    t_osc_expr* expression;
    std::string expr_string;
    
    void clear();
};
    
} /* namespace odot */
} /* namespace didl */

#endif  // EXPR_H_INCLUDED
