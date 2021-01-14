student: Horovei Andreea-Georgiana, 335CC
Tema FLEX - Limbaje formale si automate
(Varianta A)

	Pentru compilarea temei am folosit comanda "make".

	Pentru rularea temei am folosit comanda:
	 "make run TEST_FILE=test.txt", 
	unde test.txt este numele fisierul de intrare care se doreste a fi analizat dintre 
fisierele prezente in arhiva temei.

	In fiecare din cele 4 fisiere de input am definit mai multe gramatici si automate 
pentru a surprinde diversele situatii care pot aparea in analiza acestora.


	Pentru identificarea definitiei unui automat sau a unei gramatici, am 
 definit starea exclusiva numita GASESTE_NUME. In aceasta stare se poate face 
 match pe sirurile " ::= Grammar (\n" sau " ::= PushDownAutomata (\n" (identifica
 te prin regulile aferente din starea GASESTE_NUME), in fiecare situatie afisandu-se 
 numele automatului/gramaticii (memorat anterior cu yymore()), iar apoi se trece fie 
 in starea AUTOMAT, fie in starea GRAMATICA. In aceste stari se identifica elementele 
 din definitia automatului/gramaticii, pe baza altor stari exclusive asociate fiecarui 
 element care trebuie identificat si a sirurilor prezente in formatul prezentat 
 (nonterminals, alphabet, start_symbol pentru gramatica, respectiv alphabet, 
 stack_alphabet, states, final_states, initial_states pentru automat).

 ---------------------------------------------------------------------------------
 ->Detalii despre parsarea si afisarea automatelor cu stiva

 	Pentru automat, am realizat afisarea elementelor din definitie in ordinea 
 in care acestea apar in fisierul de intrare. Daca pentru automat nu apare in 
 definitie multimea de stari finale, am afisat la finalul definitiei, dupa 
 afisarea tranzitiilor, sirul ""Starile finale: {}".

 	Starile in care se poate ajunge plecand din starea AUTOMAT:

 ->ALFABET_INTRARE_AS - stare in care este afisat alfabetul de intrare al 
 automatului NUMARARE_STARI - este identificat sirul "states ::" si sunt contorizate 
 starile enumerate, urmand sa fie afisate la identicarea caracterului ; care marcheaza 
 finalul definirii starilor automatului
 ->STARE_INITIALA_AS - afiseaza starea initiala din automat
 ->STARI_FINALE_AS 
 ->ALFABET_STIVA
 ->DEFINIRE_TRANZITII - este starea in care se ajunge in una dintre urmatoarele 
 2 situatii: 
 1) daca analizorul se afla in starea AUTOMAT si a identificat un sir de forma 
 "\t"{alfabet}" -> (", marcand inceputul definirii unei tranzitii. 
 2) S-au identificat toate elementele din definitia unei tranzitii de pe randul 
 curent.

    Cand se face match pe regula <DEFINIRE_TRANZITII>{alfabet}" -> (" este 
 memorat sirul identificat (mai intai se face yyless(yyleng - 5) pentru a ignora 
 caracterele de final care nu fac parte din simbolul aferent starii de start).
 Variabila "stare" va fi folosita ulterior pentru a se putea afisa din starea 
 DEFINIRE_TRANZITII starea de start din tranzitie, aceasta actualizandu-si 
 valoarea cand se va face din nou match pe regula <DEFINIRE_TRANZITII>{alfabet}" -> (".
 (care marcheaza inceputul definirii unei noi tranzitii).

 TRANZITIE_AS - este starea in care sunt identificate elementele care alcatuiesc 
 definirea tranzitiei, fiind plasate dupa stringul de forma 
 "[stare] -> (". In aceasta stare a fost nevoie sa verific daca simbolul din 
 alfabet (reprezentand simbolul de pe banda) pe care s-a facut match este 
 variabila interna sau variabila globala.
 Am realizat aceasta verificare in partea de actiuni a regulii 
 <TRANZITIE_AS>{alfabet}", ". Mai intai am verificat daca simbolul pe care 
 s-a facut match este variabila interna, apoi, daca nu este gasita o asociere 
 pentru simbol ca si variabila interna, am verificat daca este variabila globala.
 Daca simbolul este o variabila, am afisat prima valoarea asociata acesteia din
 array-ul care retine aceste valori si, suplimentar, am folosit un string 
 (denumit variabila_tranzitie) care memoreaza simbolul curent care este variabila, 
 urmand sa verific valoarea acestuia la finalul definitii tranzitiei curente, 
 pentru a putea extinde simbolul cu toate valorile asociate lui. 

 	Extinderea simbolului cu toate valorile asociate lui se face in partea de
 actiuni a regulii <TRANZITIE_AS>{alfabet}" ;".	Simbolul din alfabet pe care se 
 face match la aceasta regula este starea la care se ajunge in tranzitie.
 	Pentru a putea extinde o variabila afisand tranzitiile complet pentru toate 
 valorile asociate acesteia, pe parcursul analizei in diferite reguli a partilor
 din definitia tranzitiei, am construit din concatenare cu yytext 2 stringuri 
 (copie_tranzitie1 respectiv copie_tranzitie2) care contin 2 substringuri din 
 tranzitia in forma in care este afisata. In cazul extinderii variabilelor, am
 folosit aceste 2 siruri, afisand sirul de forma:
 "copie_tranzitie1_valoareaVariabilaCurenta_,copie_tranzitie2" ("_" reprezinta 
 concatenare), unde valoareaVariabilaCurenta este inlocuita pe rand cu valorile 
 asociate (mai putin prima valoare asociata, aceasta fiind afisata, asa cum am
 descris anterior, in momentul identificarii variabilei).


---------------------------------------------------------------------------------
 ->Detalii despre parsarea si afisarea gramaticilor

 	In cazul gramaticilor am realizat o abordare in cadrul careia am tinut cont
 de respectarea conventiei conform careia terminalii pot fi scrisi cu litere mici 
 si/sau cifre, iar neterminalii au in denumirea formata din litere mari (eventual
 si cifre).
 	Pentru o solutie mai generala implementata anterior considerasem si situatia
 in care terminalii ar fi litere mari si pentru aceasta memorasem terminalii
 respectiv neterminalii, in cadrul regulilor care faceau match pe sirul de
 la intrare simbol cu simbol, memorand simbolul dat de yytext in multimea 
 corespunzatoare. Ulterior am renuntat la acesta idee, intrucat la analiza 
 productiilor pentru a identifica diferenta terminal/neterminal apelam functii
 care analizau explicit yytext pt a afla multimea in care este (de terminali
 sau neterminali), fapt care nu se incardra in obiectivele temei.
 	De aceea am ales abordarea in care consider respectata conventia de notare
 a terminalelor/neterminalelor. Totusi, solutia prezentata poate fi usor adaptata 
 si la situatia descrisa la inceput.
 	Multimea terminalelor este memorata, facandu-se match pe rand pe fiecare element
 al acesteia in starea MEMORARE_ALFABET_GRAMATICA; acestea este afisata dupa
 identificarea tipului de gramatica.
	In implementare am folosit reguli pentru care se poate face match la un
moment dat pe un sir care sa contina maxim 2 simboluri din alfabet (caz in care
este prezent intre acestea simbolul de concatenare); prin simbol desemnez orice 
sir descris de expresia {alfabet}.
	Am analizat productiile simbol cu simbol, in partea de actiuni 
stabilind starea urmatoare in functie de starea curenta si de natura simbolului 
(terminal/neterminal).
	
	La analiza productiilor, am folosit faptul ca daca in partea dreapta a 
productiei avem doar un neterminal, gramatica ar putea fi una regulata sau una 
independenta de context. Astfel, am definit starea TIP_2_3_GRAMATICA care verifica
daca gramatica ar putea fi una regulata prin analiza membrilor din partea dreapta
a productiilor. Daca identificam prezenta concatenarii dupa ce am facut match pe
un neterminal, deducem ca gramatica nu poate fi regulata, deci tipul cel mai
restrictiv in care s-ar putea incadra este cel al gramaticii independente de context.
Semnaland asta, trecem in starea TIP_2_1_GRAMATICA unde scopul este va vedem daca
gramatica ar putea fi GIC. Pentru asta trebuie sa verificam daca la stanga 
productiilor apare un singur neterminal. Daca gasim concatenare la stanga productiilor,
deducem ca gramatica nu poate fi GIC, deci este maxim de tipul 1, adica GDC. 
In acest caz se trece in starea TIP_1_0_GRAMATICA_ST unde suntem plasati mereu cu
analizorul la stanga productiilor si contorizam numarul de terminali si neterminali
care apar. Daca se face match pe "->", trecem in starea TIP_1_0_GRAMATICA_DR
unde contorizam cati terminali si neterminal se afla la dreapta productiei. Cand
facem match pe "|" verificam daca st > dr, caz in care am putea deduce ca 
gramatica este GFR, oprind analiza. Daca pentru toate productiile gasim ca 
st <= dr, putem incheia afisand ca gramatica este GDC.
	Am tratat in mod special cazul in care la GDC poate aparea productia S->e, 
cu conditia ca S, simbolul de start, sa nu mai apara in partea dreapta a nici unei 
alte productii. Pentru aceasta, a fost nevoie mai intai sa identific prezenta 
simbolului de start la stanga unei productii (memorand acest lucru prin 
variabila exceptie_productie), si apoi sa verific daca "e" apare in partea dreapta 
a acelei productii (daca este identificata tranzitia S->e , variabila caz_special
devine true).
	De asemenea, a fost nevoie sa contorizez aparitiile simbolului
de start in partea dreapta a productiilor pentru a verifica ulterior, in cazul in 
care s-a identificat productia S->e, ca numarul de aparitii al lui S in partea 
dreapta a productiilor este 0.
	Am adaugat in comentarii mai multe detalii despre varibilele folosite 
la identificarea exceptiei si semnificatia fiecareia.


---------------------------------------------------------------------------------
 ->Variabile interne/globale:
 	Pentru a extinde acele simboluri din alfabet care sunt variabile cu toate
 valorile care le suny asociate am considerat ca este nevoie ca variabilele sa 
 fie memorate odata ce sunt identificate. De aceea am definit starea exclusiva 
 MEMORARE_VARIABILE in care se poate face match pe un simbol din alfabet, care 
 poate fi ori numele variabilei (regula <MEMORARE_VARIABILE>{alfabet}" ::= {"),
 ori una din valorile asociate variabilei (regula <MEMORARE_VARIABILE>{alfabet}).
 In partea de actiuni a fiecarei reguli din starea MEMORARE_VARIABILE este
 memorat in mod corespunzator informatia referitoare la variabila. Mai multe 
 detalii despre structurile de date folosite pentru memorare se regasesc in 
 comentarii.


 ->Ignorare comentarii de forma  [% ... ] sau /* ... */ 
 	Pentru acest task am folosit functionalitatile de yy_push_state(state)
 respectiv yy_pop_state(), pentru a salva starea curenta in care se afla 
 analizorul la identificarea /* sau %. In oricare dintre starile existente,
 daca se identifica /* se salveaza starea curenta cu yy_push_state(YYSTATE) si 
 se trece intr-o stare COMENTARIU unde este ignorat orice caracter parcurs mai 
 putin sirul "*/", pentru acesta din urma facandu-se revenirea in starea salvata 
 de stiva, apelandu-se pentru asta "yy_pop_state()". Analog am procedat si pentru 
 comentarea continutului unei linii plasat dupa "%". In fisierele de input am 
 inclus comentariile la diverse pozitii, atat in interiorul definitiilor, cat si in
 afara acestora.
--------------------------------------------------------------------------------
Delatii despre platforma pe care am realizat tema:
	Am rulat tema pe Linux, versiunea Ubuntu 20.04.1, versiunea de gcc 
folosita este [gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0], iar versiunea flex
este [flex 2.6.4].


