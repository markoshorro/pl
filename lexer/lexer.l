/**
 * Practice Procesamiento de Lenguajes: Bloque I
 * Lexer analyzer
 *
 * Marcos Horro Varela
 * May 2016
 * v1.0
 */
%{
    /**
     * Main variables needed for counting
     */
    unsigned wordCount = 0,
	     capCount = 0,
	     lowCount = 0,
	     phraseCount = 0,
	     charCount = 0;
%}
CAP    [A-Z]+
LOWER  [a-z]+
DOT    ["."]+
DELIM  [;,]+
WS     [ \n\t]
WORD   [^("." \n\t)]+
%%
<<EOF>>             { return 0; }
{CAP}{WS}           { wordCount++; capCount++; charCount += yyleng - 1; }
{CAP}{DOT}          { wordCount++; capCount++; charCount += yyleng; phraseCount++; }
{CAP}{DELIM}        { wordCount++; capCount++; charCount += yyleng; }
{LOWER}{WS}         { wordCount++; lowCount++; charCount += yyleng - 1; }
{LOWER}{DOT}        { wordCount++; lowCount++; charCount += yyleng; phraseCount++; }
{LOWER}{DELIM}      { wordCount++; lowCount++; charCount += yyleng; }
{WORD}{DOT}         { wordCount++; charCount += yyleng; phraseCount++; }
{WORD}              { wordCount++; charCount += yyleng; }
{WS}+               { /* do nothing */ }
%%
#include <stdio.h>

int main()
{
    // Mandatory call to yylex
    yylex();
    // Output
    printf("Lexer statistics\n---------------\n");
    printf("Number of words:\t\t%d\n", wordCount);
    printf("Number of capital words:\t%d\n", capCount);
    printf("Number of lowercase words:\t%d\n", lowCount);
    printf("Number of phrases:\t\t%d\n", phraseCount);
    printf("Number of chars:\t\t%d\n", charCount);
    // Quitting program
    return 0;
}
