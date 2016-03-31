%{
#include <stdio.h>
#include <string.h>

char* course;
char* academic_year;
int n_lines = 0;
 
void yyerror(char const *);
%}
%union {
    int t_int;
    double t_double;
    char * t_str;
}
		      
%token <t_int> INTEGER
%token <t_double> DOUBLE GRADE
%token <t_str> NAME STRING NIF SUBJECT YEAR

%start S
%%
S : line {}
  ;

line : tuple
     | header
     ;

header : SUBJECT YEAR { course = $1; 
			academic_year = $2; }
       ;

tuple : NIF NAME GRADE { printf("llega\n"); }
        ;
%%

// Main function
int main(int argc, char *argv[])
{
    extern FILE *yyin;

    switch (argc) {
    case 1:
	yyin=stdin;
	yyparse();
	break;
    case 2:
	yyin = fopen(argv[1], "r");
	if (yyin == NULL) {
	    printf("error: Could not open the file.\n");
	}
	else {
	    yyparse();
	    fclose(yyin);
	}
	break;
    default: printf("error: Too many arguments.\nValid sintax: %s [in_file]\n\n", argv[0]);
    }

    printf("--> Number of lines: %d\n--> Course: %s\n--> Academic year: %s\n", n_lines, course, academic_year); 
    
    return 0;
}

// yyerror definition
void yyerror (char const *message)
{
    fprintf (stderr, "%s\n", message);
}
