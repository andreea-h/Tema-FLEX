%{ 
	#include<stdio.h>
	#include<string.h>
	int max_chars = 200;
	char* grammar = " ::= Grammar";
	char* automat = " ::= PushDownAutomata";
	char* name;
	int counter = 0;
	int numarare_stari_as = 0;
%}

%option stack
alfabet			[a-z0-9A-Z0-9]+
stare_tranzitie "\t"{alfabet}" -> ("
concatenare		[&]?
stiva 			{alfabet}{concatenare}{alfabet}

%x GRAMATICA
%x AUTOMAT
%x GASESTE_NUME

%x ALFABET_GRAMATICA
%x NETERMINALI_GRAMATICA
%x SIMBOL_START_GRAMATICA
%x PRODUCTII_GRAMATICA


%x ALFABET_INTRARE_AS
%x ALFABET_STIVA
%x STARE_INITIALA_AS
%x STARI_FINALE_AS
%x TRANZITIE_AS
%x NUMARARE_STARI

%%
<INITIAL>\n\n		{ BEGIN(GASESTE_NUME); }	
	
<INITIAL>% 			{ }	
<INITIAL>.|%		{ }


<GASESTE_NUME>" ::= Grammar (\n"  		{ name = (char *)malloc(max_chars * sizeof(char));
										  strcpy(name, yytext);
										  name[strlen(name) - 15] = '\0';	
										  printf("Numele gramaticii: %s\n", name); 
										  BEGIN(GRAMATICA); }
										  
<GASESTE_NUME>" ::= PushDownAutomata (\n"	{ name = (char *)malloc(max_chars * sizeof(char));
										  	strcpy(name, yytext);
										 	name[strlen(name) - 24] = '\0';	
										  	printf("Numele automatului: %s\n", name); 
										  	BEGIN(AUTOMAT); }
<GASESTE_NUME>"% "			{ }
<GASESTE_NUME>\n			{ }
<GASESTE_NUME>.				{ yymore(); }


<GRAMATICA>"alphabet :: "			{ BEGIN(ALFABET_GRAMATICA); printf("Alfabetul gramaticii: {"); }
<ALFABET_GRAMATICA>{alfabet}		{ printf("%s, ", yytext); } 
<ALFABET_GRAMATICA>{alfabet}" }"	{ yyless(1); printf("%s}\n", yytext); BEGIN(GRAMATICA); } 
<ALFABET_GRAMATICA>\n				{ BEGIN(GRAMATICA); }
<ALFABET_GRAMATICA>.				{ }

<GRAMATICA>.|\n { }


<AUTOMAT>"alphabet :: "				{ BEGIN(ALFABET_INTRARE_AS); printf("Alfabetul de intrare: {"); }
<ALFABET_INTRARE_AS>{alfabet}		{ printf("%s, ", yytext); } 
<ALFABET_INTRARE_AS>{alfabet}" }"	{ yyless(1); printf("%s}\n", yytext); BEGIN(AUTOMAT); } 
<ALFABET_INTRARE_AS>\n				{ BEGIN(AUTOMAT); }
<ALFABET_INTRARE_AS>.				{ }

<AUTOMAT>"states ::"				{ BEGIN(NUMARARE_STARI); }
<NUMARARE_STARI>{alfabet}			{ numarare_stari_as++; }
<NUMARARE_STARI>;					{ printf("Numarul de stari: %d\n", numarare_stari_as); 			
									  BEGIN(AUTOMAT); }
<NUMARARE_STARI>.|\n				{ }									  


<AUTOMAT>"initial_state ::"			{ printf("Starea initiala: "); BEGIN(STARE_INITIALA_AS); }
<STARE_INITIALA_AS>{alfabet}		{ printf("%s\n", yytext); }
<STARE_INITIALA_AS>\n				{ BEGIN(AUTOMAT); }
<STARE_INITIALA_AS>. 				{ }

<AUTOMAT>"final_states ::"			{ BEGIN(STARI_FINALE_AS); printf("Starile finale: {"); }
<STARI_FINALE_AS>{alfabet}			{ printf("%s, ", yytext); }
<STARI_FINALE_AS>{alfabet}" "		{ yyless(yyleng - 1); printf("%s}\n", yytext); BEGIN(AUTOMAT); } 
<STARI_FINALE_AS>\n					{ BEGIN(AUTOMAT); }
<STARI_FINALE_AS>.					{ }

<AUTOMAT>"stack_alphabet ::"		{ BEGIN(ALFABET_STIVA); printf("Alfabetul stivei: {"); }
<ALFABET_STIVA>{alfabet} 			{ printf("%s, ", yytext); }
<ALFABET_STIVA>{alfabet}" "			{ yyless(yyleng - 1); printf("%s}\n", yytext); BEGIN(AUTOMAT); } 
<ALFABET_STIVA>\n					{ BEGIN(AUTOMAT); }
<ALFABET_STIVA>.					{ }

<AUTOMAT>{stare_tranzitie}			{ BEGIN(TRANZITIE_AS); printf("Functia de tranzitie:\n"); yyless(1); }
<TRANZITIE_AS>{alfabet}", "			{ printf("%s", yytext); }
<TRANZITIE_AS>{alfabet}" /"			{ yyless(yyleng - 2); printf("%s) = (", yytext); }
<TRANZITIE_AS>{alfabet}				{ printf("\tm(%s, ", yytext); }
<TRANZITIE_AS>"/ "{stiva}			{ yy_push_state(TRANZITIE_AS); }
<TRANZITIE_AS>" -> "{alfabet}		{ printf("%s, ", yytext); yy_pop_state(); printf("%s)", yytext); }

<TRANZITIE_AS>.|\n					{ }

<AUTOMAT>.|\n   { }


%%

int yywrap(){
	return(1);
}

int main(int argc, char** argv){
	yyin = fopen(argv[1], "r");
	yylex();
	
	
	return 0;
}
