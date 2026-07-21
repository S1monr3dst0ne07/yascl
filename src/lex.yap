


seq Lex::Kind
{
    IDEN,
    BLOCK_OPEN,
    BLOCK_CLOSE,
    PAREN_OPEN,
    PAREN_CLOSE,
    ARRAY_OPEN,
    ARRAY_CLOSE,
    END_OF_STATEMENT,
    DOUBLE_QUOTE,
    SINGLE_QUOTE,
    FORMAT,
    SYMBOL,
}



seq Lex::Get(char)
{
    // isalphanum(char)
    jump iden ~ (('a' - 1) < char) & (('z' + 1) > char);
    jump iden ~ (('A' - 1) < char) & (('Z' + 1) > char);
    jump iden ~ (('0' - 1) < char) & (('9' + 1) > char);

    jump iden ~ char == '_';
    jump iden ~ char == ':';

    jump block_open  ~ char == '{';
    jump block_close ~ char == '}';

    jump paren_open  ~ char == '(';
    jump paren_close ~ char == ')';

    jump array_open  ~ char == '[';
    jump array_close ~ char == ']';

    jump end_of_statement ~ char == ';';
    jump double_quote     ~ char == '"';
    jump single_quote     ~ char == 39; // single quote

    jump format ~ char == ' ';
    jump format ~ char == 10;
    jump format ~ char ==  9;

    jump symbol;
    

    lab iden;               return Lex::Kind::IDEN;
    lab block_open;         return Lex::Kind::BLOCK_OPEN;
    lab block_close;        return Lex::Kind::BLOCK_CLOSE;
    lab paren_open;         return Lex::Kind::PAREN_OPEN;
    lab paren_close;        return Lex::Kind::PAREN_CLOSE;
    lab array_open;         return Lex::Kind::ARRAY_OPEN;
    lab array_close;        return Lex::Kind::ARRAY_CLOSE;
    lab end_of_statement;   return Lex::Kind::END_OF_STATEMENT;
    lab double_quote;       return Lex::Kind::DOUBLE_QUOTE;
    lab single_quote;       return Lex::Kind::SINGLE_QUOTE;
    lab format;             return Lex::Kind::FORMAT;
    lab symbol;             return Lex::Kind::SYMBOL;
    
}




