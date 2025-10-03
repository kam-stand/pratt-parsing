module lexer;
import token;
import std.stdio;
import std.algorithm;
import std.ascii;
import std.array;

struct Lexer
{
    Token[] tokens;
    size_t index = 0;

    Token next()
    {
        return index >= tokens.length ? Token(TokenType.Eof, '\0') : tokens[index++];
    }

    Token peek()
    {
        return index >= tokens.length ? Token(TokenType.Eof, '\0') : tokens[index];
    }
}

Lexer initLexer(byte[] input)
{
    Lexer lexer;

    lexer.tokens = input
        .filter!(it => !isWhite(it))
        .map!(
            (char ch) {
            if (isAlpha(ch) || isDigit(ch))
            {
                return Token(TokenType.Atom, ch);
            }

            else
            {
                return Token(TokenType.Op, ch);
            }
        }
        )
        .array();

    lexer.tokens ~= Token(TokenType.Eof, '\0');

    return lexer;
}

unittest
{

    byte[] input = ['1', '+', '2'];

    Lexer lex = initLexer(input);

    import std.stdio;

    foreach (t; lex.tokens)
    {
        writefln("[Type: %s | Val: %c]", t.type, t.ch);
    }

}
