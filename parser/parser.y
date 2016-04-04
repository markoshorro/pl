%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

#ifndef N
#define N 1000
#endif

extern FILE *yyin;

char* course;
char* academic_year;
char* aux;
int n_lines = 0;
int header = 0;

struct t_err {
    int n;          /* number of errors */
    char *msg[N];   /* message of the error */
    int line[N];    /* line of the error */
};

struct t_err *error;

struct t_grades {
    int n;             /* number of grades */
    double mark[N];    /* grade of student */
    char *name[N];     /* students name */
    int line[N];       /* line of mark */
};

struct t_grades *pass;
struct t_grades *fail;

/* Functions to register fails */
void reg_error(char *s, ...);
void yyerror(char *s, ...);
%}
%union {
    int t_int;
    double t_double;
    char * t_str;
}

%token CHARS PHRASE	      
%token <t_int> INTEGER
%token <t_double> DOUBLE GRADE
%token <t_str> FNAME STRING NIF SUBJECT YEAR

%start S
%%
S : /**/ | line { printf("fin?\n"); }
  ;

line : '\n' { printf("new line finish\n"); }
     | tuple line
     | header line 
     ;

header : SUBJECT YEAR { if (!header) { course = $1; academic_year = $2; header = 1;}
                        else { reg_error("Syntax error: header duplicated"); }}
       | CHARS YEAR { reg_error("Syntax error: subject bad format\n"); }
       | SUBJECT CHARS { reg_error("Syntax error: year bad format\n"); }	 
;

tuple : NIF FNAME GRADE {
                 extern yylineno;
                 if (($3>10.0)||($3<0.0)) {
                    /* error */
                    reg_error("Syntax error: grade invalid value\n");
                 } else if ($3<5.0) {
                    /* failed */
                    strcat(fail->name[fail->n], $1);
                    strcat(fail->name[fail->n], "; ");
                    strcat(fail->name[fail->n], $2);
                    fail->line[fail->n++] = yylineno;
                 } else {
                    /* passed */
                    strcat(pass->name[pass->n], $1);
                    strcat(pass->name[pass->n], "; ");
                    strcat(pass->name[pass->n], $2);
                    pass->mark[pass->n] = $3;
                    pass->line[pass->n++] = yylineno;
                 } }
       | CHARS FNAME GRADE { reg_error("Syntax error: ID bad format\n"); }
       | NIF CHARS GRADE { reg_error("Syntax error: name bad format\n"); }
       | NIF FNAME CHARS { reg_error("Syntax error: grade bad format\n"); }
       | CHARS CHARS GRADE { printf("ERROR todo\n"); }
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
    int i;
    
    error = (struct t_err *) malloc(sizeof(struct t_err));
    error->n = 0;
    for (i=0; i<N; i++) {
	error->msg[i] = (char *) malloc(N*sizeof(char));
    }

    pass = (struct t_grades *) malloc(sizeof(struct t_grades));
    pass->n = 0;
    for (i=0; i<N; i++) {
	pass->name[i] = (char *) malloc(N*sizeof(char));
    }

    fail = (struct t_grades *) malloc(sizeof(struct t_grades));
    fail->n = 0;
    for (i=0; i<N; i++) {
	fail->name[i] = (char *) malloc(N*sizeof(char));
    }    
}

void print_stats()
{
    int i;
    /* Output */
    printf("- Course: %s\n- Academic year: %s\n", course, academic_year);

    printf("=====================\nList of fails:\n");
    for (i = 0; i < fail->n; i++) {
	printf("Line %d: %s\n", fail->line[i], fail->name[i]);
    }
    printf("=====================\nList of pass:\n");
    for (i = 0; i < pass->n; i++) {
	printf("Line %d: %s; %.2f\n", pass->line[i], pass->name[i], pass->mark[i]);
    }

    
    if (error->n) {
	printf("Errors:\n");
	for (i = 0; i < error->n; i++) {
	    printf("Line %d: %s\n", error->line[i], error->msg[i]);
	}
    }
}

// yyerror definition
void yyerror(char *s, ...)
{
    extern yylineno;
    extern yytext;
    printf("%d: %s at %s\n", yylineno, s, yytext);	
}

// register errors in order to display a list of the at the end
void reg_error(char *s, ...)
{
    extern yylineno;
    error->line[error->n] = yylineno;
    error->msg[error->n++] = s;
    printf("Syntax error registered: %s\n", s);
}
