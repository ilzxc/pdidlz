/*
  ==============================================================================

    Expr.cpp
    Created: 14 Jan 2015 11:33:00pm
    Author:  Ilya Rostovtsev

  ==============================================================================
*/

#include "Expr.h"
#include "Var.h"
#include "osc_expr.h"
#include "osc_expr_parser.h"
#include "osc_bundle_s.h"
#include <iostream>

namespace didl {
namespace odot {


Expr::Expr()
: expression( nullptr ),
  expr_string( "\0" )
{
}
    
Expr::Expr( const Expr& other )
: expression( nullptr )
{
//    expression = osc_expr_alloc();
    osc_expr_copyAllLinked( &expression, other.expression );
    expr_string = other.expr_string;
}

Expr::~Expr()
{
    clear();
}
    
Expr& Expr::operator=( const Expr& rhs )
{
    if ( this == &rhs ) { return *this; }
    
    clear();
    
    osc_expr_copyAllLinked( &expression, rhs.expression );
    expr_string = rhs.expr_string;
    return *this;
    
}

void Expr::replaceExpression( const std::string& expression_string )
{
    clear();
    expr_string = expression_string;
    
    t_osc_err error = osc_expr_parser_parseExpr( expression_string.c_str(), &expression );
    
    if ( error != OSC_ERR_NONE ) {
        std::cerr << "Error in replaceExpression : " << osc_error_string( error ) << std::endl;
        //clear();
    }
}

didl::odot::Var Expr::execute( const Var& var )
{
    t_osc_err error;
    bool no_errors = true;
    
    char* scope = var.getBundle();
    long scope_length = var.getBundleLength();
    
    t_osc_bundle_s* source = osc_bundle_s_alloc( scope_length, scope );
    t_osc_bundle_s* copy = nullptr;
    osc_bundle_s_deepCopy( &copy, source );
    char* scope_copy = osc_bundle_s_getPtr( copy );
    osc_bundle_s_free( source );
    osc_bundle_s_free( copy );
    
    t_osc_expr* iterator = expression;
    t_osc_atom_ar_u* out = nullptr;
    while ( iterator ) {
        error = osc_expr_eval( iterator, &scope_length, &scope_copy, &out );

        if ( error != OSC_ERR_NONE ) {
            no_errors = false;
            std::cerr << osc_error_string( error ) << std::endl;
        }
        
        iterator = osc_expr_next( iterator );
        osc_atom_array_u_free( out );
        out = nullptr;
    }
    
    if ( no_errors ) {
        return Var( scope_copy, scope_length );
    }
    
    return Var();
}

void Expr::clear()
{
    if ( expression != nullptr ) {
        osc_expr_free( expression );
        expression = nullptr;
    }
    expr_string = "\0";
}

} /* namespace odot */
} /* namespace didl */