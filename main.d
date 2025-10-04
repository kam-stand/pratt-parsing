import lexer;
import token;
import expr;

import std.stdio;

enum PROMPT = ">> ";

int main(string[] args)
{

    while (true)
    {
        write(PROMPT);
        string line = readln();
        if (line.length < 0)
            return 1;
        auto input = cast(byte[]) line;
        //Lexer lex = initLexer(input);
        auto expr = parse(input);
        display(expr);
    }

    return 0;
}
