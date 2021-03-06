%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

#ifndef N
#define N 1000
#endif

#ifndef ERR_F
#define ERR_F "err.log"
#endif

extern FILE *yyin;
extern yylineno;
extern yytext;

char* LOG_FILE = ERR_F;
FILE* err_fptr;

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

%token NL	      
%token <t_int> INTEGER
%token <t_double> DOUBLE GRADE
%token <t_str> FNAME STRING NIF SUBJECT YEAR

%start S
%%
S : line { printf("finished parsing!\n"); }
  ;

/* left recursion better than right recursion: due to stack reasons */
line :
     | line tuple 
     | line header
     ;

header :
        SUBJECT YEAR NL { if (!header) { course = $1; academic_year = $2; header = 1;}
                        else { reg_error("Syntax error: header duplicated"); }}
	| 	error YEAR NL { reg_error("Syntax error: header subject bad format"); }
	| 	SUBJECT error NL { reg_error("Syntax error: header year bad format");  }	 
;

tuple :
        NIF FNAME GRADE NL {
                 if (($3>10.0)||($3<0.0)) {
                    /* error */
                    reg_error("Syntax error: grade invalid value");
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
	| 	error FNAME GRADE NL{ reg_error("Syntax error: ID bad format"); yyclearin; }
	| 	NIF error GRADE NL { reg_error("Syntax error: name bad format"); yyclearin; }
	| 	NIF FNAME error NL { reg_error("Syntax error: grade bad format"); yyclearin; }
        |       NIF error NL { reg_error("Syntax error: name bad format"); reg_error("Syntax error: grade bad format"); yyclearin; }
	| 	error FNAME error NL {  reg_error("Syntax error: ID bad format"); reg_error("Syntax error: grade bad format"); yyclearin; }
	|       error GRADE NL {  reg_error("Syntax error: ID bad format"); reg_error("Syntax error: name bad format"); yyclearin; }
        |       error NL { reg_error("Syntax error: bad line"); yyclearin; }
;
%%
//////////////////////////////////////////////////////
// C code

// auxiliar function to decide from where read the input
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

// initializing main structures
void init_structs()
{
    int i;

    // open log file
    err_fptr = fopen(LOG_FILE, "w+");

    if (err_fptr==NULL) {
	printf("ERROR: not possible to create or open log file!\n");
	exit(0);
    }

    // to avoid problems
    yylineno = 0;

    // intializing error struct
    error = (struct t_err *) malloc(sizeof(struct t_err));
    error->n = 0;
    for (i=0; i<N; i++) {
	error->msg[i] = (char *) malloc(N*sizeof(char));
    }

    // initializing pass structure
    pass = (struct t_grades *) malloc(sizeof(struct t_grades));
    pass->n = 0;
    for (i=0; i<N; i++) {
	pass->name[i] = (char *) malloc(N*sizeof(char));
    }

    // initializing fail structure
    fail = (struct t_grades *) malloc(sizeof(struct t_grades));
    fail->n = 0;
    for (i=0; i<N; i++) {
	fail->name[i] = (char *) malloc(N*sizeof(char));
    }    
}

// just printing the result of parsing
void print_stats()
{
    int i;

    // header
    printf("=====================\n- Course: %s\n- Academic year: %s\n", course, academic_year);

    // fails
    printf("=====================\nList of fails:\n");
    for (i = 0; i < fail->n; i++) {
	printf("Line %d: %s\n", fail->line[i], fail->name[i]);
    }

    // pass
    printf("=====================\nList of pass:\n");
    for (i = 0; i < pass->n; i++) {
	printf("Line %d: %s; %.2f\n", pass->line[i], pass->name[i], pass->mark[i]);
    }

    // error 
    if (error->n) {
	printf("=====================\nErrors:\n");
	for (i = 0; i < error->n; i++) {
	    printf("Line %d: %s\n", error->line[i], error->msg[i]);
	}
    }
}

// yyerror definition
void yyerror(char *s, ...)
{
    // yyerror into log file
    fprintf(err_fptr, "%d: %s at (%s)\n", yylineno, s, yytext);	
}

// register errors in order to display a list of the at the end
void reg_error(char *s, ...)
{
    error->line[error->n] = yylineno;
    error->msg[error->n++] = s;
}

/////////////////////////////////////////////////////////////
// Main function
int main(int argc, char *argv[])
{
    init_structs();
    open_file(argc, argv);
    print_stats();

    return 0;
}
