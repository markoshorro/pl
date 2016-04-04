%{
#include <stdio.h>
#include <string.h>

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
    char *list;
    int n;
};

struct t_err *error;

struct t_grades {
    int n;
    char *failed;
    double mark[N];
    char *passed[N];
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
                        else { reg_error("Syntax error: header duplicated"); }}
       | ERROR YEAR { reg_error("Syntax error: subject bad format\n"); }
       | SUBJECT ERROR { reg_error("Syntax error: year bad format\n"); }
;

tuple : NIF FNAME GRADE {
                 if (($3>10.0)||($3<0.0)) {
                    /* error */
                    reg_error("Syntax error: grade invalid value\n");
                 } else if ($3<5.0) {
                    /* failed */
                    strcat(grades->failed, $1);
                    strcat(grades->failed, " - ");
                    strcat(grades->failed, $2);
                    strcat(grades->failed, "\n");
                 } else {
                    /* passed */
                    strcat(grades->passed[grades->n], $1);
                    strcat(grades->passed[grades->n], " - ");
                    strcat(grades->passed[grades->n], $2);
                    grades->mark[grades->n++] = $3;
                 } }
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
    int i;
    aux = (char *) malloc(1000*sizeof(char));
    error = (struct t_err *) malloc(sizeof(struct t_err));
    error->list = (char *) malloc(N*sizeof(char));
    error->n = 0;

    grades = (struct t_grades *) malloc(sizeof(struct t_grades));
    grades->n = 0;
    for (i=0; i<N; i++) {
	grades->passed[i] = (char *) malloc(N*sizeof(char));
    }
    grades->failed = (char *) malloc(N*sizeof(char));
}

void print_stats()
{
    int i;
    /* Output */
    printf("//////////////////////\n// Output\n--> Course: %s\n--> Academic year: %s\n", course, academic_year);

    printf("=====================\nList of fails:\n");
    printf("%s\n", grades->failed);
    printf("=====================\nList of pass:\n");
    for (i = 0; i<grades->n; i++) {
	printf("%s: %.2f\n", grades->passed[i], grades->mark[i]);
    }
    
    if (error->n)
	printf("\n=====================\nNumber of errors: %d\nList of errors\n%s", error->n, error->list);
}

// yyerror definition
void yyerror(char *s, ...)
{
    extern yylineno;
    printf("Error en la línea: %d\nerror: %s\n", yylineno,s);
	
}

// register errors in order to display a list of the at the end
void reg_error(char *s, ...)
{
    extern yylineno;
    error->n++;
    strcat(error->list, "--------------\n");
    strcat(error->list, s);
    printf("Syntax error registered: %s\n", s);
}
