module token;

enum TokenType
{
    Atom,
    Op,
    Eof
}

struct Token
{
    TokenType type;
    char ch;
}
