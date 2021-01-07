student: Horovei Andreea-Georgiana, 335CC
Tema FLEX - Limbaje formale si automate
(Varianta A)

	Pentru rularea temei am folosit comanda make run TEST_FILE=test.txt, test.txt 
fiind numele fisierul de intrare care se doreste a fi analizat dintre fisierele 
prezente in arhiva temei.


	Pentru identificarea definitiei unui automat sau a unei gramatici, am 
 definit starea exclusiva numita GASESTE_NUME, in care se ajunge din starea 
 INITIAL la identificarea caracterului \n. In starea GASESTE_NUME se poate face 
 match pe sirurile " ::= Grammar (\n" sau " ::= PushDownAutomata (\n", 
 in fiecare situatie afisandu-se numele automatului/gramaticii (memorat anterior 
 cu yymore()), iar apoi se trece fie in starea AUTOMAT, fie in starea
 GRAMATICA. In aceste stari se identifica elementele din definitia automatului/
 gramaticii, pe baza altor stari exclusive asociate fiecarui element care trebuie 
 identificat si a sirurilor prezente in formatul prezentat (nonterminals, alphabet, 
 start_symbol pentru gramatica, respectiv alphabet, stack_alphabet, states, 
 final_states, initial_states pentru automat).

 	Pentru automat, am realizat afisarea elementelor din definitie in ordinea 
 in care acestea apar in fisierul de intrare. Daca pentru automat nu apare in 
 definitie multimea de stari finale, am afisat la finalul definitiei, dupa 
 afisarea tranzitiilor, sirul ""Starile finale: {".

 	Starile in care se poate ajunge plecand din starea AUTOMAT:

 ALFABET_INTRARE_AS - stare in care este afisat alfabetul de intrare al automatului
 NUMARARE_STARI - este identificat sirul "states ::" si sunt contorizate starile 
 enumerate, urmand sa fie afisate la identicarea caracterului ; care marcheaza 
 finalul definirii starilor automatului

 STARE_INITIALA_AS - afiseaza starea initiala din automat
 STARI_FINALE_AS 
 ALFABET_STIVA

 DEFINIRE_TRANZITII - este starea in care se ajunge daca analizorul se afla in 
 starea AUTOMAT si a identificat un sir de forma "\t"{alfabet}" -> (", marcand 
 inceputul definirii unei tranzitii. In aceasta stare, daca este identificat 
 sirul "\t) ;\n", se revine in starea AUTOMAT. 
    Cand se face match pe regula <DEFINIRE_TRANZITII>{alfabet}" -> (", este 
 afisat un string de forma "m([stare], ", unde 'stare' este simbolul identificat 
 din alfabet(adica valoarea din yytext, dupa apelul "yyless(yyleng - 5)" 
 - pentru a fi ignorate simbolurile " -> (" ). De asemenea, este memorata starea 
 gasita (in variabila "stare") pentru a se putea afisa ulterior in cazul in care 
 exista definite mai multe tranzitii pentru aceeasi stare de start. 

 TRANZITIE_AS - este starea in care sunt identificate elementele care alcatuiesc 
 definirea tranzitiei, fiind plasate dupa stringul de forma 
 "[stare] -> (". In aceasta stare a fost nevoie sa verific daca simbolul din 
 alfabet pe care s-a facut match este variabila interna sau variabila globala.
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
 actiuni a regulii <TRANZITIE_AS>{alfabet}" ;\n".	
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





 Variabile interne/globale:

Delatii despre platforma pe care am realizat tema:
	Am rulat tema pe Linux, versiunea Ubuntu 20.04.1, versiunea de gcc 
folosita este [gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0] iat versiunea flex
este [flex 2.6.4].

