	/*student: Horovei Andreea-Georgiana, 335CC*/
%{ 
	#include<stdio.h>
	#include<string.h>
	int max_chars = 200;
	char* grammar = " ::= Grammar";
	char* automat = " ::= PushDownAutomata";
	char* stiva; /*retine ce trebuie pus pe stiva la o tranzitie*/
	char* stare; /*retine starea curenta pentru care se face scrierea unei tranzitii*/
	char* name;
	int afisare_tranzitii; /*are valoarea 1 daca s-a afisat deja mesajul "Functia de tranzitie: ", altfel este 0*/
	int counter = 0;
	int numarare_stari_as = 0;
%}

%option stack
%option 8bit full
alfabet			[a-z0-9A-Z0-9]+
stare_tranzitie "\t"{alfabet}" -> ("
concatenare		&?
stiva 			{alfabet}{concatenare}{alfabet}

%x GRAMATICA
%x AUTOMAT
%x GASESTE_NUME

%x COMENTARIU

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
%x STIVA
%x DEFINIRE_TRANZITII

%%
<INITIAL>\n\n		{ BEGIN(GASESTE_NUME); }	
	
<INITIAL>% 			{ }	
<INITIAL>.|%		{ }


<GASESTE_NUME>" ::= Grammar (\n"  			{ yyless(yyleng - strlen(" ::= Grammar (\n"));
										  	  printf("Numele gramaticii: %s\n", yytext); 
										  	  BEGIN(GRAMATICA); }
										  
<GASESTE_NUME>" ::= PushDownAutomata (\n"	{ yyless(yyleng - strlen(" ::= PushDownAutomata (\n"));
										  	  printf("Numele automatului: %s\n", yytext); 
										  	  BEGIN(AUTOMAT); }
<GASESTE_NUME>"% "			{ }
<GASESTE_NUME>\n			{ }
	/*oricare alte caractere analizata in aceasta stare alcatuiesc numele cautat si sunt memorate*/
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

	/*este identificat inceputul definirii functiilor de tranzitie, sirul pe care s-a facut match va fi reanalizat mai departe*/
<AUTOMAT>{stare_tranzitie}			{ BEGIN(DEFINIRE_TRANZITII); 
									  if (afisare_tranzitii == 0) {
									  	printf("Functia de tranzitie:\n");
									  	afisare_tranzitii = 1;
									  }  
									  yyless(0);
									}
	
<DEFINIRE_TRANZITII>{alfabet}" -> (" { yyless(yyleng - 5); printf("\tm(%s, ", yytext); stare = strdup(yytext); BEGIN(TRANZITIE_AS); }
	/*regula care se aplica cand sunt definite mai multe tranzitii pentru aceeasi stare*/
<DEFINIRE_TRANZITII>{alfabet}		{ printf("\tm(%s, ", stare); 
									  BEGIN(TRANZITIE_AS); yyless(0); }
<DEFINIRE_TRANZITII>.|\n			{ }
<TRANZITIE_AS>{alfabet}", "			{ printf("%s", yytext); }
<TRANZITIE_AS>{alfabet}" / " 		{ yyless(yyleng - 3); printf("%s) = ", yytext); }
<TRANZITIE_AS>{stiva}" -> "			{ yyless(yyleng - 4);
									  stiva = strdup(yytext); }
<TRANZITIE_AS>"e -> "				{ yyless(yyleng - 4);
									  stiva = strdup(yytext); }	
	/*este identificata starea urmatoare dintr-o tranzitie*/	
	/*s-a incheiat scrierea unei tranzitii*/								  								  	
<TRANZITIE_AS>{alfabet}" ;\n"		{ yyless(yyleng - 3); 
									  printf("(%s, ", yytext); 
									  printf("%s)\n", stiva); 
									  BEGIN(DEFINIRE_TRANZITII); }
	/*este identificat finalul definitiei unei tranzitii*/
<DEFINIRE_TRANZITII>"\t) ;\n"		{ BEGIN(AUTOMAT); }
<TRANZITIE_AS>.|\n					{ }

	/*daca din oricare dintre stari se gaseste /*, trebuie sa ignoram tot continutul comentariului*/
<*>"/*"								{ int before_comment_state = YYSTATE;
							          yy_push_state(before_comment_state);
									  BEGIN(COMENTARIU); }
	/*igonora orice caracter de input pana la **/
<COMENTARIU>[^*]				    {  }
	/*s-a identificat finalul comenatiului si se revine la starea de dinainte de gasirea comentariului*/
<COMENTARIU>"*/\n"					{ yy_pop_state(); }

<*>") ;;"							{ BEGIN(INITIAL); numarare_stari_as = 0; afisare_tranzitii = 0; printf("\n"); }

<AUTOMAT>.|\n   { }


%%

	/*analiza se face dintr-un singur fisier*/
int yywrap(){
	return(1);
}

int main(int argc, char** argv){
	yyin = fopen(argv[1], "r");
	yylex();
	
	
	printf("%d\n", counter);
	return 0;
}
