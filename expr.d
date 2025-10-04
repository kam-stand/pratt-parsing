/*
 * Pratt parser for simple arithmetic expressions
 * Based on: https://eli.thegreenplace.net/2010/01/02/top-down-operator-precedence-parsing
 */

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
    auto lit = new Literal(value);
    auto expr = new Expression();
    expr.type = ExprType.Literal;
    expr.lit = lit;
    return expr;
}

Expression* makeBinary(Expression* lhs, Token op, Expression* rhs)
{
    auto bin = new Binary(lhs, op, rhs);
    auto expr = new Expression();
    expr.type = ExprType.Binary;
    expr.bin = bin;
    return expr;
}

void display(Expression* expr)
{
    switch (expr.type)
    {
    case ExprType.Literal:
        writefln("LITERAL: [TYPE: %s] | [VAL: %c]", expr.lit.value.type, expr.lit.value.ch);
        break;
    case ExprType.Binary:
        writeln("BINARY: ");
        display(expr.bin.lhs);
        writefln("  OPERATION: [TYPE: %s] | [VAL: %c]", expr.bin.op.type, expr.bin.op.ch);
        display(expr.bin.rhs);
        break;
    default:
        break;
    }
}

Expression* parse(byte[] input)
{
    auto lex = initLexer(input);
    return parse_bp(lex, 0);
}

// ---------------- Pratt core ----------------

Expression* parse_bp(ref Lexer lex, int min_bp)
{
    // prefix or literal
    auto t = lex.next();
    auto left = parseNud(lex, t);

    while (true)
    {
        auto op = lex.peek();
        if (op.type == TokenType.Eof)
            break;

        int lbp, rbp;
        if (!infixBindingPower(op, lbp, rbp))
            break;

        if (lbp < min_bp)
            break;

        lex.next(); // consume operator
        auto right = parse_bp(lex, rbp);
        left = makeBinary(left, op, right);
    }

    return left;
}

// ---------------- nud / led ----------------

Expression* parseNud(ref Lexer lex, Token t)
{
    switch (t.type)
    {
    case TokenType.Atom:
        // Just a literal value like '1' or 'x'
        return makeLiteral(t);

    case TokenType.Op:
        // Handle prefix/unary operators like -x or +x
        if (t.ch == '-' || t.ch == '+')
        {
            // Assign a high binding power for unary so it binds tightly
            int rbp = 5;
            auto rhs = parse_bp(lex, rbp);

            // Represent -x as (0 - x) for simplicity
            auto zero = makeLiteral(Token(TokenType.Atom, '0'));
            return makeBinary(zero, t, rhs);
        }
        break;

    default:
        break;
    }

    throw new Exception("Unexpected token in nud: " ~ t.ch);
}

// No led() needed since handled inline in parse_bp

// ---------------- Binding powers ----------------

bool infixBindingPower(Token op, out int lbp, out int rbp)
{
    switch (op.ch)
    {
    case '+':
    case '-':
        lbp = 1;
        rbp = 2;
        return true;
    case '*':
    case '/':
        lbp = 3;
        rbp = 4;
        return true;
    default:
        return false;
    }
}

// ---------------- Tests ----------------

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
