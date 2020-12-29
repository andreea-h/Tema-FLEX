	/*student: Horovei Andreea-Georgiana, 335CC*/
%{ 
	#include<stdio.h>
	#include<string.h>
	#include<stdbool.h>
	
	#define MAX_VARIABLES 200 /*numarul maxim de variabile care pot aparea in fisierul de intrare*/
	
	int max_chars = 200;
	char* grammar = " ::= Grammar";
	char* automat = " ::= PushDownAutomata";
	char* stiva; /*retine ce trebuie pus pe stiva la o tranzitie*/
	char* stare; /*retine starea curenta pentru care se face scrierea unei tranzitii*/
	char* name;
	int afisare_tranzitii; /*are valoarea 1 daca s-a afisat deja mesajul "Functia de tranzitie: ", altfel este 0*/
	int counter = 0;
	int numarare_stari_as = 0;
	bool stari_finale = false; /*devine true daca exista stari finale in definitia unui AS*/
	bool afisare_automat = false; /*devine true daca la momentul curent este afisata definitia unui automat*/
	bool gramatica = false; /*devine true daca la momentul curent este afisata definit unei gramatici*/
	
	char* variabile[MAX_VARIABLES];
	int nr_variabile; /*retine dimensiunea pentru vectorul de variabile*/
	
	char* valori_variabile[MAX_VARIABLES][2]; /*memoreaza asocierile variabila-valoare gasite in fisier*/
	int nr_valori; /*retine numarul de asocieri valori-variabile identificate in cadrul analizei*/
	char* variabila_curenta; /*retine variabila curenta pentru care se memoreaza valorile*/
	
	
	/*aceleasi structuri pentru memorarea varibilelor sunt definite si pentru varibilele interne definitiei unui automat/gramatici*/
	/*aceste structuri sunt dezalocate la finalul definirii automatului/gramaticii curente*/
	char* variabile_interne[MAX_VARIABLES];
	int nr_variabile_interne; /*retine dimensiunea pentru vectorul de variabile interne definite in interiorul unei structuri*/
	
	char* valori_variabile_interne[MAX_VARIABLES][2]; /*memoreaza asocierile variabila - valoare gasite in defintia curenta*/
	int nr_valori_interne; /*retine numarul de asocieri valori-variabile identificate in cadrul analizei*/
	bool variabila_interna = false; /*devine true daca se face memorarea variabilei ca varibila interna*/

	char* variabila_tranzitie; /*retine valoarea unei variabile identificata in definitia unui AS/unei gramatici*/

	/*primeste un simbol si intoarce 1 daca simbolul respectiv este memorat ca variabila globala*/
	int verifica_variabila_globala(char* simbol) { 
		int i;
		for (i = 0; i < nr_variabile; i++) { 
			if (strcmp(simbol, variabile[i]) == 0) {
				return 1;
			}
		}
		return 0;
	} 
	
	/*primeste un simbol si intoarce 1 daca simbolul respectiv este memorat ca variabila locala*/
	int verifica_variabila_interna(char* simbol) { 
		int i;
		for (i = 0; i < nr_variabile_interne; i++) { 
			if (strcmp(simbol, variabile_interne[i]) == 0) {
				return 1;
			}
		}
		return 0;
	} 
	
	/*intoarce indicele primei aparitii a variabilei in vectorul de valori asociate variabilelor globale*/
	int prima_aparitie(char* simbol) {
		int i;
		for (i = 0; i < nr_valori; i++) {
			if (strcmp(valori_variabile[i][0], simbol) == 0) {
				return i;
			}
		}
		return -1;
	}
	
	/*intoarce indicele primei aparitii a variabilei in vectorul de valori asociate variabilelor locale definitiei curente*/
	int prima_aparitie_interna(char* simbol) {
		int i;
		for (i = 0; i < nr_valori; i++) {
			if (strcmp(valori_variabile_interne[i][0], simbol) == 0) {
				return i;
			}
		}
		return -1;
	}
	
	char* copie_tranzitie1; /*memoreaza o copie a tranzitiei pentru a face afisarea la explicitarea varibilelor*/
	char* copie_tranzitie2;
	
	bool varibila_interna; /*devine true daca variabila identificata in tranzitia curenta este variabila interna*/
	
	void free_variabile_locale() {
		int i;
		for (i = 0; i < nr_variabile_interne; i++) {
			free(variabile_interne[i]);
		}
		nr_variabile_interne = 0;
	}
	
	void free_valori_var_locale() {
		int i;
		for (i = 0; i < nr_valori_interne; i++) {
			free(valori_variabile_interne[i][0]);
			free(valori_variabile_interne[i][1]);
			valori_variabile_interne[i][0] = NULL;
			valori_variabile_interne[i][1] = NULL;
		}
		nr_valori_interne = 0;
	}
	
	/*variabile si functii pentru prelucrarea gramaticii si determinarea tipul acesteia*/
	char* neterminale[MAX_VARIABLES];
	int nr_neterminale;
	char* alfabet[MAX_VARIABLES];
	int nr_simb_alfabet; /*numarul de simboluri ale alfabetului*/
	char* simbol_start;
	
	/*intorce 1 daca simbol este neterminal, altfel intoarce -1*/
	int check_neterminal(char* simbol) {
		int i;
		for (i = 0; i < nr_neterminale; i++) {
			if (strcmp(simbol, neterminale[i]) == 0) {
				return 1;
			}	
		}
		return -1;
	}
	
	/*intoarce 1 daca simbol este terminal, alfel intoarce -1*/
	int check_terminal(char* simbol) {
		int i;
		for (i = 0; i < nr_simb_alfabet; i++) {
			if (strcmp(simbol, alfabet[i]) == 0) {
				return 1;
			}
		}
		return -1;
	}
	
	/*afisare alfabet gramatica*/
	void print_alfabet() {
		printf("Alfabetul gramaticii: {");
		int i;
		for (i = 0; i < nr_simb_alfabet; i++) {
			if (i != nr_simb_alfabet - 1) {
				printf("%s, ", alfabet[i]);
			}
			else {
				printf("%s}", alfabet[i]);
			}	
		}
		printf("\n");
	}
%}

%option stack

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

%x MEMORARE_VARIABILE

%x MEMORARE_ALFABET_GRAMATICA
%x MEMORARE_NETERMINALI
%x MEMORARE_SIMBOL_START


%x TIP_2_3_GRAMATICA
	/*gramatica poate fi maxim de tipul 2*/
%x TIP_2_1_GRAMATICA 
%x VERIFICA_TIP_3

%%
						  
	/*s-a gasit o variabila in starea INITIAL, se va memora ca variabila gloabal impreuna cu valorile asociate acesteia*/									  	
<INITIAL,GASESTE_NUME>"variable "			{ int before_variable_state = YYSTATE;
							          		  yy_push_state(before_variable_state);
							          		  BEGIN(MEMORARE_VARIABILE); }	
	/*s-a gasit o variabila intr-una dintre starile AUTOMAT/GRAMATICA, se va memora ca variabila interna*/									  	
<AUTOMAT,GRAMATICA>"variable "				{ int before_variable_state = YYSTATE;
							          		  yy_push_state(before_variable_state);
							          		  BEGIN(MEMORARE_VARIABILE);
							          		  variabila_interna = true; }							          		  
							          		  
<MEMORARE_VARIABILE>{alfabet}" ::= {" 		{ yyless(yyleng - strlen(" ::= {")); 
											  if (variabila_interna == true) { /*variabila gasita trebuie memorata ca variabila interna*/
											  	variabile_interne[nr_variabile_interne++] = strdup(yytext);
												variabila_curenta = strdup(yytext);
										      }
										      else { /*este memorata o valoare pentru o variabia globala*/
										      	variabile[nr_variabile++] = strdup(yytext);
												variabila_curenta = strdup(yytext);		
										      }
										    }		
										    
<MEMORARE_VARIABILE>{alfabet}				{ if (variabila_interna == false) {
												  valori_variabile[nr_valori][0] = strdup(variabila_curenta);
												  valori_variabile[nr_valori][1] = strdup(yytext);
												  nr_valori++;
											  }
											  else {
												  valori_variabile_interne[nr_valori_interne][0] = strdup(variabila_curenta);
												  valori_variabile_interne[nr_valori_interne][1] = strdup(yytext);
												  nr_valori_interne++;
											  }
											}
	/*s-a identificat finalul definirii unei varibile*/									      	  
<MEMORARE_VARIABILE>" } ;"					{ yy_pop_state(); variabila_interna = false; }					  
<MEMORARE_VARIABILE>.|\n					{ }				





<INITIAL>\n\n			{ BEGIN(GASESTE_NUME); }	
	
<INITIAL>% 				{ }	
<INITIAL>.|\n			{ yymore(); }


<GASESTE_NUME,INITIAL>" ::= Grammar (\n"  	{ yyless(yyleng - strlen(" ::= Grammar (\n"));
										  	  printf("Numele gramaticii: %s\n", yytext); 
										  	  BEGIN(GRAMATICA); }
										  
<GASESTE_NUME,INITIAL>" ::= PushDownAutomata (\n"	{ yyless(yyleng - strlen(" ::= PushDownAutomata (\n"));
										  	  		  printf("Numele automatului: %s\n", yytext); 
										  	  		  afisare_automat = true;
										  	  		  BEGIN(AUTOMAT); }
<GASESTE_NUME>"% "			{ }
<GASESTE_NUME>\n			{ }
	/*oricare alte caractere analizata in aceasta stare alcatuiesc numele cautat si sunt memorate*/
<GASESTE_NUME>.						{ yymore(); }


	/*incepe definitia alfabetului gramaticii*/
<GRAMATICA>"alphabet :: "					{ BEGIN(MEMORARE_ALFABET_GRAMATICA); }
	/*este memorat simbolul din alfabet continut in yytext*/
<MEMORARE_ALFABET_GRAMATICA>{alfabet}		{ alfabet[nr_simb_alfabet++] = strdup(yytext);} 
	/*este identificat ultimul simbol din alfabet; s-a incheiat definitia alfebtului => se revine la starea GRAMATICA*/
<MEMORARE_ALFABET_GRAMATICA>{alfabet}" } ;"	{ yyless(yyleng - 4); alfabet[nr_simb_alfabet] = strdup(yytext); BEGIN(GRAMATICA); } 
<MEMORARE_ALFABET_GRAMATICA>.				{ }

	/*incepe definitia multimii neterminalelor*/
<GRAMATICA>"nonterminals :: "				{ BEGIN(MEMORARE_NETERMINALI); }
	/*este memorat simbolul din alfabet continut in yytext*/
<MEMORARE_NETERMINALI>{alfabet}				{ neterminale[nr_neterminale++] = strdup(yytext); } 
	/*este identificat ultimul neterminal; s-a incheiat definitia multimii neterminalelor => se revine la starea GRAMATICA*/
<MEMORARE_NETERMINALI>{alfabet}" } ;"		{ yyless(yyleng - 4); neterminale[nr_neterminale] = strdup(yytext); BEGIN(GRAMATICA); } 
<MEMORARE_NETERMINALI>.						{ }

<GRAMATICA>"start_symbol :: "				{ BEGIN(MEMORARE_SIMBOL_START); }
	/*este identificat simbolul de start*/
<MEMORARE_SIMBOL_START>{alfabet}" ;"		{ yyless(yyleng - 2); simbol_start = strdup(yytext); BEGIN(GRAMATICA); }


	/*este identificata o productie pt care in partea dreapta gasim un singur neterminal*/	
<GRAMATICA>"\t"{alfabet}" -> "	{ 
	/*presupunem ca avem GR sau GIC*/
	BEGIN(TIP_2_3_GRAMATICA);	
}

<TIP_2_3_GRAMATICA>{alfabet}	{
	/*verifica daca ceea ce urmeaza dupa neterminal contine terminali*/
	if (check_neterminal(yytext) == 1) {	
		yy_push_state(YYSTATE); /*salveaza starea curenta*/
		BEGIN(VERIFICA_TIP_3); /*verifica ce urmeaza dupa neterminalul curent*/
	}
}


<TIP_2_3_GRAMATICA>"&"				{ } 
	/*s-a terminat analiza productiei de pe linia curenta; la acest match stim ca productia tocmai analizata indica GR*/
<TIP_2_3_GRAMATICA>" ;\n"			{ BEGIN(GRAMATICA); }
<TIP_2_3_GRAMATICA>" ;\n) ;;\n"		{ printf("Tipul gramaticii: GR\n"); BEGIN(INITIAL); print_alfabet(); }
<TIP_2_3_GRAMATICA>.|\n				{ }

	/*daca dupa un neterminal avem alti neterminali sau terminali, gramatica nu poate fi GR*/
<VERIFICA_TIP_3>"&"{alfabet}		{ BEGIN(TIP_2_1_GRAMATICA); }	
<VERIFICA_TIP_3>" "					{ yyless(0); yy_pop_state(); }

	
<GRAMATICA>.|\n 					{ }


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

	/*s-a identificat definitia starilor finale la AS*/
<AUTOMAT>"final_states ::"			{ BEGIN(STARI_FINALE_AS); printf("Starile finale: {"); stari_finale = true; }
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
	
<DEFINIRE_TRANZITII>{alfabet}" -> (" { yyless(yyleng - 5); printf("\tm(%s, ", yytext); stare = strdup(yytext); BEGIN(TRANZITIE_AS);
									   copie_tranzitie1 = (char*)malloc(150 * sizeof(char)); 
									   sprintf(copie_tranzitie1, "\tm(%s, ", yytext); /*este memorat string-ul aferent tranzitiei curente*/
									 }
	/*regula care se aplica cand sunt definite mai multe tranzitii pentru aceeasi stare*/
<DEFINIRE_TRANZITII>{alfabet}		{ printf("\tm(%s, ", stare); 
									  BEGIN(TRANZITIE_AS); yyless(0); }
<DEFINIRE_TRANZITII>.|\n			{ }
<TRANZITIE_AS>{alfabet}", "			{ yyless(yyleng - 2);
									  /*verifica daca simbolul analizat este varibila interna definitiei curente*/
									  if (verifica_variabila_interna(yytext) == 0) { /*simbolul nu este variabila interna*/
										  /*verifica daca simbolul analizat este variabila globala*/
										  if (verifica_variabila_globala(yytext) == 0) {
										  	printf("%s, ", yytext);
										  }
										  else { /*este afisata prima valoare pe care o are asociata variabila globala*/
										  	printf("%s, ", valori_variabile[prima_aparitie(yytext)][1]);
										  	variabila_tranzitie = strdup(yytext);
										  }
									  }
									  else {
									  	variabila_interna = true;
									  	printf("%s, ", valori_variabile_interne[prima_aparitie_interna(yytext)][1]);
										variabila_tranzitie = strdup(yytext);
									  }
									}
<TRANZITIE_AS>{alfabet}" / " 		{ yyless(yyleng - 3); printf("%s) = ", yytext); 
									  char* aux = (char*)malloc(100 * sizeof(char)); 
									  sprintf(aux, "%s) = ", yytext);
									  copie_tranzitie2 = strdup(aux);
									}
<TRANZITIE_AS>{stiva}" -> "			{ yyless(yyleng - 4);
									  stiva = strdup(yytext); }
<TRANZITIE_AS>"e -> "				{ yyless(yyleng - 4);
									  stiva = strdup(yytext); }	
	/*este identificata starea urmatoare dintr-o tranzitie*/	
	/*s-a incheiat scrierea unei tranzitii*/								  								  	
<TRANZITIE_AS>{alfabet}" ;\n"		{ yyless(yyleng - 3); 
									  printf("(%s, ", yytext); 
									  char* aux1 = (char*)malloc(100 * sizeof(char)); sprintf(aux1, "(%s, ", yytext);
									  copie_tranzitie2 = strcat(copie_tranzitie2, aux1);
									  printf("%s)\n", stiva); 
									  char* aux2 = (char*)malloc(100 * sizeof(char)); sprintf(aux2, "%s)\n", stiva);
									  copie_tranzitie2 = strcat(copie_tranzitie2, aux2);
									  int i;
	/*daca anterior s-a identificat o variabila care trebuie extinsa, vor fi afisate si tranzitiile coresp. celorlalte valori ale variabilei*/
									  if (variabila_tranzitie != NULL) {
									  	int i;
									  	/*prima valoare asociata a fost deja afisata la identificarea variabilei*/
									  	if (variabila_interna == false) {
										  	int first = -1;
										  	for (i = 0; i < nr_valori; i++) {
												if (strcmp(valori_variabile[i][0], variabila_tranzitie) == 0) {
													if (first == -1) {
														first = i;
													}
													if (i != first) {
														printf("%s%s, %s", copie_tranzitie1, valori_variabile[i][1], copie_tranzitie2);
													}
												}
											}
										}
										else { /*sunt afisate valorile asociate variabilei locale*/
											int first = -1;
										  	for (i = 0; i < nr_valori_interne; i++) {
												if (strcmp(valori_variabile_interne[i][0], variabila_tranzitie) == 0) {
													if (first == -1) {
														first = i;
													}
													if (i != first) {
														printf("%s%s, %s", copie_tranzitie1, valori_variabile_interne[i][1], copie_tranzitie2);
													}
												}
											}
										}
										variabila_interna = false;
									  	free(variabila_tranzitie);
									  	variabila_tranzitie = NULL;
									  }
									  BEGIN(DEFINIRE_TRANZITII); }
	/*este identificat finalul definitiei unei tranzitii*/
<DEFINIRE_TRANZITII>"\t) ;\n"		{ BEGIN(AUTOMAT); }
<TRANZITIE_AS>.|\n					{ }

	/*daca din oricare dintre stari se gaseste /*, trebuie sa ignoram tot continutul comentariului*/
<*>"/*"								{ int before_comment_state = YYSTATE;
							          yy_push_state(before_comment_state);
									  BEGIN(COMENTARIU); }
	/*igonora orice caracter de input pana la caracterul * */
<COMENTARIU>[^*]				    {  }
	/*s-a identificat finalul comentariului si se revine la starea de dinainte de gasirea comentariului*/
<COMENTARIU>"*/\n"					{ yy_pop_state(); }
	/*s-a identificat finalul definitiei unui automat sau a unei gramatici*/
	/*se verifica daca au fost definite starile finale*/
	/*daca nu au fost define stari finale, se va afisa mesajul aferent cand multimea starilor finale este vida*/
<*>") ;;"							{ if (afisare_automat == true && stari_finale == false) {
									  	printf("Starile finale: {}\n");
								      }
									  BEGIN(INITIAL); 
									  numarare_stari_as = 0; 
									  afisare_tranzitii = 0; 
									  stari_finale = false;
									  afisare_automat = false;
									  printf("\n"); 
									  /*trebuie sterse variabilele locale memorate pentru definitia curenta de automat/gramatica*/ 
									  if (valori_variabile_interne != NULL) {
									  	free_variabile_locale();
									  	free_valori_var_locale();
									  }
									 }
<AUTOMAT>.|\n   					 { }


%%

	/*analiza se face dintr-un singur fisier*/
int yywrap(){
	return(1);
}

int main(int argc, char** argv){
	yyin = fopen(argv[1], "r");
	yylex();
	
	/*
	printf("variabile globale: \n");
	int i;
	for (i = 0; i < nr_variabile; i++) {
		printf("%s ", variabile[i]);
	}
	printf("\nvalorile pentru variabilele gloabale: \n");
	
	for (i = 0; i < nr_valori; i++) {
		printf("%s %s\n", valori_variabile[i][0], valori_variabile[i][1]);
	}
	
	printf("variabile locale: \n");
	for (i = 0; i < nr_variabile_interne; i++) { 
		printf("%s ", variabile_interne[i]);
	}
	
	printf("\nvalorile pentru variabilele interne: \n");
	
	for (i = 0; i < nr_valori_interne; i++) {
		printf("%s %s\n", valori_variabile_interne[i][0], valori_variabile_interne[i][1]);
	}*/
	return 0;
}


















