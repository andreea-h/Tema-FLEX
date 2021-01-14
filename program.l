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
		for (i = 0; i < nr_valori_interne; i++) {
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
	
	/*afisare alfabet gramatica*/
	void print_alfabet() {
		printf("Alfabetul gramaticii: {");
		int i;
		for (i = 0; i <= nr_simb_alfabet; i++) {
			if (i != nr_simb_alfabet) {
				printf("%s, ", alfabet[i]);
			}
			else {
				printf("%s}\n", alfabet[i]);
			}	
		}
		printf("\n");
	}
	
	/*elibereaza memoria alocata pentru a retine el. din alfabet, neterminalii, simb, de start*/
	void free_buffers() {
		int i;
		for (i = 0; i <= nr_neterminale; i++) {
			free(neterminale[i]);
			neterminale[i] = NULL;
		}
		nr_neterminale = 0;
		
		for (i = 0; i <= nr_simb_alfabet; i++) {
			free(alfabet[i]);
			alfabet[i] = NULL;
		}
		nr_simb_alfabet = 0;
	
	}
	
	/*retine numarul de simboluri din stanga si din dreapta productiei*/
	int st = 0;
	int dr = 0;
	
	bool tip_gasit_gfr = false; /*devine true daca a fost identificat si afisat tipul de gramatica (GFR)*/
	bool caz_special = false; /*este true daca a fost gasita tranzitia simbol_start->e*/
	bool exceptie_productie = false;/*este true cand productia curenta care se analizeaza are in partea stanga DOAR simbolul de start*/
	int check_start_symbol = 0; /*retine de cate ori apare simbolul de start in partea dreapta a unei productii pt GDC sau GFR*/
	
	bool maxim_gdc; /*este true daca tipul cel mai restrictiv in care s-ar incadra gramatica este GIC*/
	bool tranz_e; /*este true daca a fost identificata o tranzitie de forma neterminal->e (neterminal!=S) la gfr*/
	
	bool neterminal_st; /*este true daca in partea stanga a productiei avem un singur neterminal*/
%}

%option stack

alfabet			[a-z0-9A-Z0-9]+
stare_tranzitie "\t"{alfabet}" -> ("
concatenare		&?
stiva 			{alfabet}{concatenare}

neterminal 		[A-Z][A-Z0-9A-Z0-9]*
terminal        [a-z0-9a-z0-9]+

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
	/*gramatica poate fi maxim de tipul 1*/
%x TIP_1_0_GRAMATICA_ST
%x TIP_1_0_GRAMATICA_DR

%x COMENTARIU_LINIE

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
	/*este identificat numele variabilei care se va memora*/							          		  
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
<MEMORARE_VARIABILE>" } ;"					{ yy_pop_state(); variabila_interna = false;  }					  
<MEMORARE_VARIABILE>.|\n					{ }				





<INITIAL>\n 					{ BEGIN(GASESTE_NUME); }	
	
<INITIAL>"%"					{ }	
<INITIAL>.						{ yymore(); }


<GASESTE_NUME,INITIAL>" ::= Grammar (\n"  	{ yyless(yyleng - strlen(" ::= Grammar (\n"));
										  	  printf("Numele gramaticii: %s\n", yytext); 
										  	  BEGIN(GRAMATICA); }
										  
<GASESTE_NUME,INITIAL>" ::= PushDownAutomata (\n"	{ yyless(yyleng - strlen(" ::= PushDownAutomata (\n"));
										  	  		  printf("Numele automatului: %s\n", yytext); 
										  	  		  afisare_automat = true;
										  	  		  BEGIN(AUTOMAT); }
<GASESTE_NUME>"% "									{ }
<GASESTE_NUME>\n									{ }
	/*oricare alte caractere analizata in aceasta stare alcatuiesc numele cautat si sunt memorate*/
<GASESTE_NUME>.										{ yymore(); }


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
	/*este identificata prezenta simbolului de start in stanga unei productii*/
	yyless(yyleng - 4);
	if (strcmp(simbol_start, yytext + 1) == 0) {
		exceptie_productie = true;
	}
	else {
		neterminal_st = true; /*la stanga productiei gasim in simbol neterminal diferit de simbolul de start*/
	}
}
	/*daca in partea stanga a unei productii este gasit &, gramatica poate fi maxim GDC*/
<GRAMATICA>"\t"{alfabet}"&"{alfabet}	{ st = 2; BEGIN(TIP_1_0_GRAMATICA_ST); }
	/*sunt identificate simbolurile din partea dreapta a productiei*/
<TIP_2_3_GRAMATICA>{neterminal}			{
	
	yy_push_state(YYSTATE); /*salveaza starea curenta*/
	BEGIN(VERIFICA_TIP_3); /*verifica ce urmeaza dupa neterminalul curent*/
	if (strcmp(yytext, simbol_start) == 0 ) {
		/*incrementeaza numarul de aparitii ale simbolului de start in partea dreapta a unei productii*/
		check_start_symbol++;
	}		
}

<TIP_2_3_GRAMATICA>"e"			    {
										if (exceptie_productie == true) {
												caz_special = true;
										}
										
										if (neterminal_st == true) {
											tranz_e = true;
										}	
									}

<TIP_2_3_GRAMATICA>{terminal}		{ }

<TIP_2_3_GRAMATICA>"&"				{ } 
	/*s-a terminat analiza productiei de pe linia curenta; la acest match stim ca productia tocmai analizata indica GR*/
<TIP_2_3_GRAMATICA>" ;\n"			{ BEGIN(GRAMATICA); neterminal_st = false; }
<TIP_2_3_GRAMATICA>" ;\n) ;;"		{ printf("Tipul gramaticii: GR\n");
									  BEGIN(INITIAL); print_alfabet();  /*afiseaza alfabetul gramaticii*/
									  free_buffers(); 
									  exceptie_productie = false; 
									  caz_special = false; 
									  check_start_symbol = 0;
									  neterminal_st = false; 
									  tranz_e = false;
									}
<TIP_2_3_GRAMATICA>.|\n				{ }

	/*daca dupa un neterminal avem alti neterminali sau terminali, gramatica nu poate fi GR*/
	/*se trece in starea TIP_2_1_GRAMATICA unde se verifica partea stanga a productiilor pt a distinge intre GIC si GDC*/
<VERIFICA_TIP_3>"&"{alfabet}		{ if (strcmp(yytext, simbol_start) == 0) { 
											check_start_symbol++; 
										} 
										BEGIN(TIP_2_1_GRAMATICA); }	
<VERIFICA_TIP_3>" "					{ yyless(0); yy_pop_state(); }


	/*stare in care se ajunge dupa ce am identificat ca gramatica poate fi maxim de tip 2*/
	/*verificam daca productiile pastreaza in partea stanga un singur neterminal*/
<TIP_2_1_GRAMATICA>"\t"{alfabet}" -> "  	{ }
	/*daca este identificat simbol de concatenare in partea stanga a productiei, gramatica nu poate fi GIC*/
<TIP_2_1_GRAMATICA>"\t"{alfabet}"&"	 		{ st = 1; BEGIN(TIP_1_0_GRAMATICA_ST); }
<TIP_2_1_GRAMATICA>" ;\n) ;;\n"				{ printf("Tipul gramaticii: GIC\n"); 
											  BEGIN(INITIAL); print_alfabet(); 
											  free_buffers(); 
											  check_start_symbol = 0; 
											  exceptie_productie = false; /*reseteaza valorile la finalul productiei curente*/
											  caz_special = false; 
											  check_start_symbol = 0;
											  neterminal_st = false;
											  tranz_e = false;
											}
										
	/*la identificarea lui e, este verificat daca apare tranzitia simbol_start->e*/
<TIP_2_1_GRAMATICA>"e"						{ 
	if (exceptie_productie == true) { /*daca a fost gasit simbolul de start in partea stanga a unei productii*/
		/*a fost identificata tranzitia S->e*/
		caz_special = true; 
	}
	if (neterminal_st == true) {
		tranz_e = true;
	}
}
<TIP_2_1_GRAMATICA>{alfabet}				{
	if (strcmp(yytext, simbol_start) == 0) {
		check_start_symbol++;
	}
}
<TIP_2_1_GRAMATICA>\n						{ }
<TIP_2_1_GRAMATICA>.						{ }



	/*sunt numarate simbolurile din partea stanga a productiei curente*/
<TIP_1_0_GRAMATICA_ST,TIP_2_1_GRAMATICA>{alfabet}	    { st++; }
<TIP_1_0_GRAMATICA_ST,TIP_2_1_GRAMATICA>" -> " 			{ BEGIN(TIP_1_0_GRAMATICA_DR); }
<TIP_1_0_GRAMATICA_ST,TIP_2_1_GRAMATICA>"%"				{ int before_comment_state = YYSTATE;
							              				  yy_push_state(before_comment_state);
									      				  BEGIN(COMENTARIU_LINIE);
									    				 }
<TIP_1_0_GRAMATICA_ST>"/*"				{ int before_comment_state = YYSTATE;
							              yy_push_state(before_comment_state);
									      BEGIN(COMENTARIU);
									    }	
<TIP_1_0_GRAMATICA_ST>") ;;\n"	        { 
	if (tranz_e == true) {
		/*daca a fost gasita o tranzitie de forma neterminal->e si regula |alpha|<=|beta| a fost respectata pt 
		toate celelalte productii*/
		printf("Tipul gramaticii: GFR\n");
		tip_gasit_gfr = true;
		print_alfabet(); 
		free_buffers();
	}			
	if (maxim_gdc == true && tip_gasit_gfr == false) {
		
		if (caz_special == false || ((caz_special == true) && (check_start_symbol == 0))) {
			printf("Tipul gramaticii: GDC\n");
			print_alfabet(); 
			free_buffers();
		}
		else if ((caz_special == true) && (check_start_symbol != 0)) {
			/*daca exista S->e si S apare in partea dreapta a unei productii, avem GFR*/
			printf("Tipul gramaticii: GFR\n");
			tip_gasit_gfr = true;
			print_alfabet(); 
			free_buffers();
		}																			
	}
	tip_gasit_gfr = false;
	exceptie_productie = false;
	caz_special = false;
	check_start_symbol = 0;
	maxim_gdc = false;
	tranz_e = false;
	st = 0;
	dr = 0;
	BEGIN(INITIAL); 	
}	
							    								    
<TIP_1_0_GRAMATICA_ST>.|\n				{ }

<TIP_1_0_GRAMATICA_DR>"e"				{ dr = 0; }

<TIP_1_0_GRAMATICA_DR>{alfabet}			{ 
	
	dr++; 
	
	/*sunt numarate aparitiile simbolului de start in partea dreapta a productiilor*/
	if (strcmp(simbol_start, yytext) == 0) {
		if (exceptie_productie == true) {
			check_start_symbol++; 
		}
	}
}
	/*trebuie verificat st <= dr pt productia curenta*/
<TIP_1_0_GRAMATICA_DR>"|"				{ 
	if (st > dr) {
		printf("Tipul gramaticii: GFR\n"); 
		BEGIN(INITIAL); 
		print_alfabet();
		free_buffers();
		tip_gasit_gfr = true;
		exceptie_productie = false;
		caz_special = false;
		check_start_symbol = 0;
	}
	dr = 0;
}	
	/*la finalul liniei este resetat st; la acest moment gramatica poate fi GDC sau GFR; daca st>dr gramatica este GFR*/
<TIP_1_0_GRAMATICA_DR>";"			{ 
	if (st > dr) {
		printf("Tipul gramaticii: GFR\n"); 
		BEGIN(INITIAL); 
		print_alfabet();
		free_buffers();
		tip_gasit_gfr = true;
		exceptie_productie = false;
		caz_special = false;
		check_start_symbol = 0;
	}
	
	maxim_gdc = true;
	st = 0; 
	dr = 0; 
	BEGIN(TIP_1_0_GRAMATICA_ST); 
}
	/*daca s-a ajuns la finalul definitiei gramaticii in acesta stare, se verifica daca s-a identificat exceptia cu S->e*/
<TIP_1_0_GRAMATICA_DR>" ;\n) ;;\n"	{ 
	/*daca a fost gasita productia S->e, se verifica numarul de aparitii al simbolului de start in partea dreapta a productiilor*/
	if (tip_gasit_gfr == false) {
		if ((caz_special == false && tranz_e == false) || ((caz_special == true) && (check_start_symbol == 0) && (tranz_e == false))) {
			printf("Tipul gramaticii: GDC\n");
			print_alfabet(); 
			free_buffers();
		}
		else if (((caz_special == true) && (check_start_symbol == 0) && (tranz_e == true))) {
			printf("Tipul gramaticii: GFR\n");
			print_alfabet(); 
			free_buffers();
		}
		else if ((caz_special == true) && (check_start_symbol != 0)) {
			/*daca exista S->e si S apare in partea dreapta a unei productii, avem GFR*/
			printf("Tipul gramaticii: GFR\n");
			print_alfabet(); 
			free_buffers();
		}
		/*a fost identificata a tranzitie de forma neterminal->e (neterminal!=S)*/
		else if (tranz_e == true) {
			printf("Tipul gramaticii: GFR\n");
			print_alfabet(); 
			free_buffers();
		}
	}
	tip_gasit_gfr = false;
	exceptie_productie = false;
	caz_special = false;
	check_start_symbol = 0;
	maxim_gdc = false;
	tranz_e = false;
	neterminal_st = false;
	neterminal_st = false;
	st = 0;
	dr = 0;
	BEGIN(INITIAL); 
}

<TIP_1_0_GRAMATICA_DR>.				{ }

<GRAMATICA>.|\n 					{ }

<AUTOMAT>"%"					    { int before_comment_state = YYSTATE;
									   yy_push_state(before_comment_state);
									   BEGIN(COMENTARIU_LINIE); 
									}
<COMENTARIU_LINIE>\n				{ yy_pop_state(); }
<COMENTARIU_LINIE>.					{ }	


<AUTOMAT>"alphabet :: "				{ BEGIN(ALFABET_INTRARE_AS); printf("Alfabetul de intrare: {");  }
<ALFABET_INTRARE_AS>{alfabet}		{ printf("%s, ", yytext); } 
<ALFABET_INTRARE_AS>{alfabet}" }"	{ yyless(1); printf("%s}\n", yytext); BEGIN(AUTOMAT); } 
<ALFABET_INTRARE_AS>\n				{ BEGIN(AUTOMAT); }
<ALFABET_INTRARE_AS>.				{ }

<AUTOMAT>"states ::"				{ BEGIN(NUMARARE_STARI); }
<NUMARARE_STARI>{alfabet}			{ numarare_stari_as++; }
<NUMARARE_STARI>;					{ printf("Numarul de stari: %d\n", numarare_stari_as); 			
									  BEGIN(AUTOMAT); 
									  numarare_stari_as = 0; }
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
<AUTOMAT>{stare_tranzitie}			 { BEGIN(DEFINIRE_TRANZITII); 
									  if (afisare_tranzitii == 0) {
									  	printf("Functia de tranzitie:\n");
									  	afisare_tranzitii = 1;
									  }  
									  yyless(0); /*sirul pe care s-a facut match va fi reanalizat*/
									 }
									
	/*este identificata starea 'de start' a unei tranzitii*/
<DEFINIRE_TRANZITII>{alfabet}" -> (" {  yyless(yyleng - 5); 
										stare = strdup(yytext); /*este memorata starea initiala pentru a fi afisata ulterior*/
										BEGIN(TRANZITIE_AS);
										/*copie_tranzitie1 este folosit ulterior la afisare daca exista variabile in tranzitie*/
									    copie_tranzitie1 = (char*)malloc(150 * sizeof(char)); 
									    sprintf(copie_tranzitie1, "\tm(%s, ", yytext); 
									    /*este memorat string-ul aferent incepututlui tranzitiei curente*/
									 }
	/*regula care afiseaza starea initiala dintr-o tranzitie*/
	/*la acet moment analizorul a identificat si simbolul de pe banda*/
	/*sirul curent match-uit va fi reanalizat pt afisarea simbolului de pe banda*/
<DEFINIRE_TRANZITII>{alfabet}		{ printf("\tm(%s, ", stare); 
									  BEGIN(TRANZITIE_AS); yyless(0); 
									}
									
	/*este identificat elementul din alfabet prezent in tranzitia curenta analizata (adica valoarea de pe banda)*/
	/*trebuie verificat daca simbolul asociat sirului curent de pe banda este variabila globala/interna*/
<TRANZITIE_AS>{alfabet}", "			{ yyless(yyleng - 2);
									  /*verifica daca simbolul analizat este variabila interna definitiei curente*/
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
	/*este identificat simbolul asociat cu varful stivei*/								
<TRANZITIE_AS>{alfabet}" /" 		{ yyless(yyleng - 2); printf("%s) = ", yytext); 
									  char* aux = (char*)malloc(100 * sizeof(char)); 
									  sprintf(aux, "%s) = ", yytext);
									  copie_tranzitie2 = strdup(aux);
									}
	/*este identificat si memorat noul sir care se pune in varful stivei*/										
<TRANZITIE_AS>{stiva}{1,}" -> "|{alfabet}" -> "		{ yyless(yyleng - 4);
									  			  	  stiva = strdup(yytext); 
											   		 }
	/*este identificata starea urmatoare dintr-o tranzitie*/	
	/*deci s-a incheiat definirea unei tranzitii*/								  								  	
<TRANZITIE_AS>{alfabet}" ;"		    { yyless(yyleng - 2); 
									  printf("(%s, ", yytext); 
									  char* aux1 = (char*)malloc(100 * sizeof(char)); 
									  /*la acest moment yytext retine starea urmatoare din tranzitia curenta*/
									  sprintf(aux1, "(%s, ", yytext);
									  copie_tranzitie2 = strcat(copie_tranzitie2, aux1);
									  /*stiva a fost identificat si memorat in cadrul unei reguli anterioare, reprezentand ce se va pune pe stiva in tranzitia curenta*/
									  printf("%s)\n", stiva); 
									  char* aux2 = (char*)malloc(100 * sizeof(char)); 
									  sprintf(aux2, "%s)\n", stiva);
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
														printf("%s%s, %s", copie_tranzitie1, 
														valori_variabile_interne[i][1], copie_tranzitie2);
													}
												}
											}
										}
										variabila_interna = false;
									  	free(variabila_tranzitie);
									  	variabila_tranzitie = NULL;
									  }
									  BEGIN(DEFINIRE_TRANZITII); }
									  						  
	/*daca este identificat un comentariu pe linia unde se defineste o tranzitie*/									  	
<TRANZITIE_AS,DEFINIRE_TRANZITII>"%"	{ int before_comment_state = YYSTATE;
							              yy_push_state(before_comment_state);
									      BEGIN(COMENTARIU_LINIE);
									    }								  
	/*este identificat finalul definitiei unei tranzitii*/
<DEFINIRE_TRANZITII>"\t) ;\n"		   { BEGIN(AUTOMAT); }


<TRANZITIE_AS,DEFINIRE_TRANZITII>"\t%" { int before_comment_state = YYSTATE;
							             yy_push_state(before_comment_state);
									     BEGIN(COMENTARIU_LINIE);
									   }
	/*este regula pe care se face match dupa identificarea starii de start din definirea unei tranzitii*/									   	
<TRANZITIE_AS>\n					   { BEGIN(DEFINIRE_TRANZITII); }			   
<DEFINIRE_TRANZITII>.|\n			   { }					   
<TRANZITIE_AS>. 					   { }



	/*daca din oricare dintre stari se gaseste /*, trebuie sa ignoram tot continutul comentariului*/
<*>"/*"								{ int before_comment_state = YYSTATE;
							          yy_push_state(before_comment_state);
									  BEGIN(COMENTARIU); }
	/*igonora orice caracter de input pana la caracterul * */
<COMENTARIU>.|\n					{  }
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
	
	
	return 0;
}
