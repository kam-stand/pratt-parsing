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
    expr.type = ExprType.Literal;
    expr.lit = lit;
    return expr;

}

Expression* makeBinary(Expression* lhs, Token op, Expression* rhs)
{

    Binary* bin = new Binary(lhs, op, rhs);
    Expression* expr = new Expression();
    expr.type = ExprType.Binary;
    expr.bin = bin;
    return expr;
}

void display(Expression* expr)
{

    switch (expr.type)
    {
    case ExprType.Literal:
        writefln("\tLITERAL: [TYPE: %s] | [VAL: %c]", expr.lit.value.type, expr.lit.value.ch);
        break;
    case ExprType.Binary:
        writeln("BINARY: ");
        display(expr.bin.lhs);
        writefln("\tOPERATION: [TYPE: %s] | [VAL: %c]", expr.bin.op.type, expr.bin.op.ch);
        display(expr.bin.rhs);
        break;
    default:
        break;
    }
}

unittest
{
    auto lit = makeLiteral(Token(TokenType.Atom, '1'));
    assert(lit.type == ExprType.Literal);
}

unittest
{
    Expression* lhs = makeLiteral(Token(TokenType.Atom, '1'));
    Expression* rhs = makeLiteral(Token(TokenType.Atom, '2'));
    Token op = Token(TokenType.Op, '+');

    Expression* bin = makeBinary(lhs, op, rhs);
    assert(bin.type == ExprType.Binary);
    assert(bin.bin.lhs.lit.value.ch == '1');

    display(bin);

}
