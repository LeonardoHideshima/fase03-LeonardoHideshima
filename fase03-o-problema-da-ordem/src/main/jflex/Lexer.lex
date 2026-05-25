package br.maua.cic303;

import java_cup.runtime.Symbol; // Importação necessária para o CUP

%%

%class Lexer
%public
%unicode
%cup       // <-- CRÍTICO: Esta diretiva ativa a integração com o CUP
%line
%column

%{
    // Funções auxiliares para gerar objetos Symbol para o CUP
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

/* ========================================================================= */
/* MACROS (Expressões Regulares Auxiliares)                                  */
/* ========================================================================= */
LineTerminator = \r|\n|\r\n
WhiteSpace     = {LineTerminator} | [ \t\f]

/* Número: aceita inteiro, decimal, e notação científica (ex: 6.02E23, 6.62e-34) */
Number = [0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?

/* Identificador: começa com letra, seguido de letras/dígitos/_ (máx 32 chars) */
Letter = [a-zA-Z]
Digit  = [0-9]
Identifier        = {Letter}({Letter}|{Digit}|_){0,31}
OversizedIdentifier = {Letter}({Letter}|{Digit}|_){32,}

%%
/* ========================================================================= */
/* REGRAS LÉXICAS                                                             */
/* ========================================================================= */

<YYINITIAL> {
    
    /* Regra para ignorar espaços em branco */
    {WhiteSpace}    { /* Não faz nada */ }

    /* Palavras Reservadas — devem vir ANTES da regra de Identifier */
    "if"            { return symbol(sym.IF); }
    "then"          { return symbol(sym.THEN); }
    "else"          { return symbol(sym.ELSE); }
    "while"         { return symbol(sym.WHILE); }

    /* Pontuação */
    "("             { return symbol(sym.LPAREN); }
    ")"             { return symbol(sym.RPAREN); }
    "{"             { return symbol(sym.LBRACE); }
    "}"             { return symbol(sym.RBRACE); }
    ";"             { return symbol(sym.SEMI); }

    /* Operadores Relacionais — operadores duplos ANTES dos simples */
    "=="            { return symbol(sym.REL_OP, yytext()); }
    "!="            { return symbol(sym.REL_OP, yytext()); }
    "<="            { return symbol(sym.REL_OP, yytext()); }
    ">="            { return symbol(sym.REL_OP, yytext()); }
    "<"             { return symbol(sym.REL_OP, yytext()); }
    ">"             { return symbol(sym.REL_OP, yytext()); }

    /* Atribuição — DEPOIS dos relacionais para não conflitar com == */
    "="             { return symbol(sym.ASSIGN); }

    /* Operadores Aritméticos */
    "+" | "-"       { return symbol(sym.ADD_OP, yytext()); }
    "*" | "/" | "%" { return symbol(sym.MUL_OP, yytext()); }

    /* Regras para as Macros */
    {Identifier}    { return symbol(sym.ID, yytext()); }
    {Number}        { return symbol(sym.NUMBER, yytext()); }

    /* Identificadores grandes demais (Captura o erro) */
    {OversizedIdentifier} { throw new RuntimeException("Erro Léxico: Identificador gigante -> " + yytext()); }

    /* Fallback: Qualquer outro caractere não reconhecido gera um Erro */
    .   { throw new RuntimeException("Erro Léxico: Caractere Ilegal -> " + yytext()); }
}

/* Regra para o Final do Arquivo */
<<EOF>>             { return symbol(sym.EOF, ""); }
