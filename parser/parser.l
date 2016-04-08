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
ws              [ \t]
NIF     	{digit}{8}"-"{cap}
WORDS    	[a-zA-Z ]+
FNAME   	{cap}?{letter}+" "{cap}?{letter}+", "{cap}?{letter}+
GRADE           1?[0-9]{1}"."[0-9]{2}
YEAR    	{digit}{4}"/"{digit}{4}
HEADER          "Identificador\tAlumno\t\t\t\tNota\n"
IGNORE          " - Curso "|{ws}+
%%
{NIF}		  { yylval.t_str = strdup(yytext); return NIF;}
{WORDS}/" -"      { yylval.t_str = strdup(yytext); return SUBJECT; }
{YEAR}            { yylval.t_str = strdup(yytext); return YEAR;}
{FNAME}           { yylval.t_str = strdup(yytext); return FNAME;}
{GRADE}           { yylval.t_double = atof(yytext); return GRADE;}
{IGNORE}|{HEADER} { /* ignore */}
"\n"              { return NL; }
.		  { /* error */ }
%%
 // C code
