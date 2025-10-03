module expr;
import token;
import lexer;
import std.stdio;

enum ExprType
{
    Literal,
    Binary
}

struct Literal
{
    Token value;
}

struct Binary
{
    Expression* lhs;
    Token op;
    Expression* rhs;
}

struct Expression
{
    ExprType type;
    union
    {
        Literal* lit;
        Binary* bin;
    }
}

Expression* makeLiteral(Token value)
{
    Literal* lit = new Literal(value);
    Expression* expr = new Expression();
    expr.ExprType = ExprType.Literal;
    expr.lit = lit;
    return expr;

}

Expression* makeBinary(Expression* lhs, Token op, Expression* rhs)
{

    Binary* bin = new Binary(lhs, op, rhs);
    Expression* expr = new Expression();
    expr.ExprType = ExprType.Binary;
    expr.bin = bin;
    return expr;
}
