%{
#include <stdio.h>
#include <string.h>

extern FILE *yyin;

char* course;
char* academic_year;
int n_lines = 0;
int header = 0;

struct t_err {
    char *list;
    int n;
};

struct t_err *error;

struct t_grades {
    char *passed;
    char *failed;
};

struct t_grades *grades;

void reg_error(char *s, ...);
void yyerror(char *s, ...);
%}
%union {
    int t_int;
    double t_double;
    char * t_str;
}

%token ERROR		      
%token <t_int> INTEGER
%token <t_double> DOUBLE GRADE
%token <t_str> FNAME STRING NIF SUBJECT YEAR

%start S
%%
S : /**/ | line { printf("fin?\n"); }
  ;

line : '\n'
     | tuple line '\n'
     | header line '\n'
     ;

header : SUBJECT YEAR { if (!header) { course = $1; academic_year = $2; header = 1;}
                        else { yyerror("Syntax error: header duplicated"); }}
       | ERROR YEAR { reg_error("Syntax error: subject bad format\n"); }
       | SUBJECT ERROR { reg_error("Syntax error: year bad format\n"); }
;

tuple : NIF FNAME GRADE { printf("llega a tuple\n"); }
       | ERROR FNAME GRADE { reg_error("Syntax error: ID bad format\n"); }
       | NIF ERROR GRADE { reg_error("Syntax error: name bad format\n"); }
       | NIF FNAME ERROR { reg_error("Syntax error: grade bad format\n"); }
;
%%
//////////////////////////////////////////////////////
// C code

void open_file(int argc, char argv[])
{
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
}

// Main function
int main(int argc, char *argv[])
{
    init_structs();
    open_file(argc, argv);
    print_stats();

    return 0;
}

void init_structs()
{
    error = (struct t_err *) malloc(sizeof(struct t_err));
    error->list = (char *) malloc(1000*sizeof(char));
    error->n = 0;

    grades = (struct t_grades *) malloc(sizeof(struct t_grades));
    grades->passed = (char *) malloc(1000*sizeof(char));
    grades->failed = (char *) malloc(1000*sizeof(char));
}

void print_stats()
{
    /* Output */
    printf("//////////////////////\n// Output\n--> Course: %s\n--> Academic year: %s\n", course, academic_year);
    if (error->n)
	printf("Number of errors: %d\nList of errors\n%s", error->n, error->list);
}

// yyerror definition
void yyerror(char *s, ...)
{
    extern yylineno;
    printf("Error en la línea: %d\nerror: %s\n", yylineno,s);
	
}

void reg_error(char *s, ...)
{
    extern yylineno;
    error->n++;
    strcat(error->list, "--------------\n");
    strcat(error->list, s);
    printf("Syntax error registered: %s\n", s);
}
