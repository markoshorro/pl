%{
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

char* aux;
int i;

%}
			DIGIT   	[0-9]
			CAP     	[A-Z]
			LETTER  	[a-zA-Z]
			WORD    	[a-zA-Z ]
			NIF     	{DIGIT}{8}"-"{CAP}
			FNAME   	{CAP}{LETTER}+" "{CAP}{LETTER}+", "{CAP}{LETTER}+
			SUBJECT 	{WORD}+"-"
			YEAR    	{DIGIT}+"/"{DIGIT}+
%%

{NIF}		{ yylval.t_str = yytext; return NIF;}
{SUBJECT}	{ yylval.t_str = strdup(yytext); return SUBJECT; }
{YEAR}		{ yylval.t_str = strdup(yytext); return YEAR;}
.		{/* nothing */}
%%
 // C code
