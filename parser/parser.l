%option yylineno noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

char* aux;
int i;
%}
digit   	[0-9]
cap     	[A-Z]
letter  	[a-zA-Z]
word    	[a-zA-Z ]
ws              [ \t\n]
NIF     	{digit}{8}"-"{cap}
FNAME   	{cap}?{letter}+" "{cap}?{letter}+", "{cap}?{letter}+
GRADE           1?[0-9]{1}"."[0-9]{2}
YEAR    	{digit}{4}"/"{digit}{4}
IGNORE          "Curso"|"Alumno"|"Identificador"|"Nota"|" -"|{ws}+
CHAR            {letter}*|{digit}*
PHRASE          {CHAR}+{ws}+
%%
{NIF}		{ yylval.t_str = strdup(yytext); return NIF;}
{word}+/" -"    { yylval.t_str = strdup(yytext); return SUBJECT; }
{YEAR}		{ yylval.t_str = strdup(yytext); return YEAR;}
{FNAME}         { yylval.t_str = strdup(yytext); return FNAME;}
{GRADE}         { yylval.t_double = atof(yytext); return GRADE;}
{IGNORE}        { /* DO NOTHING */}
{CHARS}         { return CHARS; }
.		{ yyerror("unrecognized"); }
%%
 // C code
