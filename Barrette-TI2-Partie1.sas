ODS PDF FILE = "C:\SAS\TI2\Barrette_TI2_Partie1.pdf";

TITLE "MATH20605 � Travail individuel 2 � Partie 1 � C�dric Barrette";

*QUESTION 1: Lecture de donn�es brutes;
libname bibli2 "C:\SAS\TI2\Donn�es";

DATA bibli2.data1;
	infile "C:\SAS\TI2\Donn�es\Donnees2005.txt" DLM='09'x DSD;
		* Les caract�res "'09'x" sont utilis�s pour repr�sent� les espaces de type "tab";
		* le DSD est utilis� pour identifier les valeurs manquantes;

	input 
		NO : $25. 
		CityPop : comma5.
		Metro $ 
		CountyFips $ 
		Ownership : $6. 
		MortgageStatus : $45. 
		HHincome : comma10.
		HomeValue : comma10.
		City : $45.
		MortgagePayment : comma10. 
		;

	label
		NO = "Identification de la propri�t�"
		CityPop = "Population de la ville"
		Metro = "R�gion m�tropolitaine"
		CountyFips = "Code"
		Ownership = "Propri�t�"
		MortgageStatus = "Situation hypoth�caire"
		HHincome = "Revenu familial"
		HomeValue = "Valeur de la propri�t�"
		City = "Ville"
		MortgagePayment = "Paiement hypoth�caire"
		;

	format
		NO $15.
		CityPop 4.
		Metro $1.
		CountyFips $3.
		Ownership $6. 
		MortgageStatus $45. 
		HHincome dollar15.2
		HomeValue dollar15.2
		City $45.
		MortgagePayment dollar10.2
		;
RUN;


*QUESTION 2: Rapport sur les 30 premi�res observations;
PROC PRINT data=bibli2.data1 (obs=30) label;
	ID NO;
RUN;

*QUESTION 3: V�rification des valeurs de la variable MortgagePayment;
PROC MEANS data=bibli2.data1 maxdec=1 max min n nmiss q1 median q3 mean;
	var MortgagePayment;
RUN;

	*R�PONSE QUESTION3: La valeur minimale est de -1500$. Consid�rant que cette variable repr�sente le montant qui doit 
						�tre vers� � la banque pour l'hypoth�que, un montant n�gatif n'est pas plausible non. 

*QUESTION 4: Lecture des donn�es brutes de MortgagePayment en format texte;

DATA data2;
	infile "C:\SAS\TI2\Donn�es\Donnees2005.txt" DLM='09'x DSD;
		*MortgagePaymentC est identifi�e comme une variable alphanum�rique (texte) gr�ce au "$";
	input 
		NO : $25. 
		CityPop : comma5.
		Metro $ 
		CountyFips $ 
		Ownership : $6. 
		MortgageStatus : $45. 
		HHincome : comma10.
		HomeValue : comma10.
		City : $45.
		MortgagePaymentC : $10. 
		;
			*maintenant, la conversion de la variable MortgagePayment en format texte vers le format num�rique;
		MortgagePayment = input(MortgagePaymentC, dollar20.);

	label
		NO = "Identification de la propri�t�"
		CityPop = "Population de la ville"
		Metro = "R�gion m�tropolitaine"
		CountyFips = "Code"
		Ownership = "Propri�t�"
		MortgageStatus = "Situation hypoth�caire"
		HHincome = "Revenu familial"
		HomeValue = "Valeur de la propri�t�"
		City = "Ville"
		MortgagePayment = "Paiement hypoth�caire"
		;

	format
		NO $15.
		CityPop 4.
		Metro $1.
		CountyFips $3.
		Ownership $6. 
		MortgageStatus $45. 
		HHincome dollar15.2
		HomeValue dollar15.2
		City $45.
		MortgagePaymentC $20.
		MortgagePayment dollar20.
		;
RUN;

PROC PRINT data=data2 (obs=30) label;
	ID NO;
	Where MortgagePayment=.;
RUN;

*R�PONSE QUESTION 4: Comme on peut le voir gr�ce � l'impression, lorsque MortgagePayment affiche une valeur manquante,
					 les valeurs MortgagePaymentC correspondantes sont compos�es de O plut�t que de 0 (z�ro) ce qui semble
					 caus� une erreur lorsque SAS essaye de lire ces caract�res en format num�rique;

*QUESTION 5: Corrections des valeurs de MortgagePayment;

DATA data3;
	set data2;
	MortgagePaymentC = tranwrd(MortgagePaymentC, "O", "0");
	MortgagePayment = input(MortgagePaymentC, dollar20.);
	If MortgagePayment<0 then MortgagePayment=MortgagePayment*(-1);
Run;

PROC MEANS data=data3 maxdec=1 min nmiss;
	var MortgagePayment;
RUN;

*QUESTION 6: Validation des variables de type texte : Ownership, MortgageStatus et City;

PROC FREQ data=data3;
	tables Ownership MortgageStatus City;
RUN;

*QUESTION 7: Correction des valeurs des variables de type texte : Ownership, MortgageStatus et City;
	*Afin de r�pondre � cette question en modifiant les variables tout en utilisant data3, je vais recopier les �tapes 
	pr�c�dentes en lien avec la table de donn�es data3 puis y ajouter le code pour la question 7;

DATA data3;
	set data2;
	MortgagePaymentC = tranwrd(MortgagePaymentC, "O", "0");
	MortgagePayment = input(MortgagePaymentC, dollar20.);
	If MortgagePayment<0 then MortgagePayment=MortgagePayment*(-1);


		*D�BUT DE LA QUESTION 7;
	city=compbl(city);
	If city="Not in identifiable city (or size group" then city="Not in identifiable city (or size group)";
	Ownership=propcase(ownership);
	MortgageStatus=tranwrd(MortgageStatus,"\","/");
	MortgageStatus=tranwrd(MortgageStatus,"-","/");
		*� l'aide des deux �nonc�s suivants, j'ajoute un espace � toutes les barres obliques, puis utilise la fonction
		"compbl" pour enlever les double espaces;
	MortgageStatus=tranwrd(MortgageStatus,"/","/ ");
	MortgageStatus=compbl(MortgageStatus);
RUN;

*QUESTION 8: V�rification des valeurs des variables de type texte : Ownership, MortgageStatus et City;

PROC FREQ data=data3 order=freq;
	tables Ownership MortgageStatus City;
RUN;

*R�PONSE QUESTION 8: 
	City: La ville la plus repr�sent�e dans la table de donn�es est "New York" qui se trouve dans l'�tat de New York (NY).
	Ownership: le pourcentage de r�sidences occup�es par des propri�taires est de 73,83%;

*QUESTION 9: Cr�ation d�un format pour l�affichage des �tiquettes de valeurs de la variable Metro;

PROC FORMAT;
		*La variable "Metro" est alphanum�rique";
	value $metro 
		0="Not identifiable"
		1="Not in Metro Area"
		2="Metro, Inside City"
		3="Metro, Outside City"
		4="Metro, City Status Unknown";
RUN;

PROC FREQ data=data3;
	tables metro;
	format metro $metro.;
RUN;

*QUESTION 10: Statistiques descriptives de MortgagePayment selon Ownership;

PROC MEANS data=data3;
	var MortgagePayment;
	class Ownership;
RUN;

*R�PONSE QUESTION 10: Effectivement, les r�sultats me semblent plausibles;

*QUESTION 11: V�rification des valeurs pour les variables num�riques HomeValue et HHincome;

PROC UNIVARIATE data=data3 noprint;
	var HomeValue HHIncome;
	histogram HomeValue HHIncome;
	class Ownership;
Run;

*R�PONSE QUESTION 11: Pour simplifier l'impression de la proc�dure Univariate et pour n'avoir que les histogrammes des deux variables,
					  l'option "noprint" a �t� utilis�e, mais pour permettre de r�pondre � cette question avec plus d'exactitude,
					  j'ai enlev�e cette option et j'ai �t� en mesure de lire les r�ponses dans les rapport produit.

					  Le revenu familial le plus faible rapport�e par un propri�taire: -29 997$
					  Le revenu familial le plus faible rapport�e par un locataire: -19 998$
					  La valeur de la r�sidence la plus dispendieuse: 9 999 999$ (pour des locataires d'ailleurs);

*QUESTION 12: Correction des valeurs pour les variables num�riques HomeValue et HHIncome;

	*Afin de r�pondre � cette question en modifiant les variables tout en utilisant data3, je vais recopier les �tapes 
	pr�c�dentes en lien avec la table de donn�es data3 puis y ajouter le code pour la question 12;

DATA data3;
	set data2;
	MortgagePaymentC = tranwrd(MortgagePaymentC, "O", "0");
	MortgagePayment = input(MortgagePaymentC, dollar20.);
	If MortgagePayment<0 then MortgagePayment=MortgagePayment*(-1);
	city=compbl(city);
	If city="Not in identifiable city (or size group" then city="Not in identifiable city (or size group)";
	Ownership=propcase(ownership);
	MortgageStatus=tranwrd(MortgageStatus,"\","/");
	MortgageStatus=tranwrd(MortgageStatus,"-","/");
	MortgageStatus=tranwrd(MortgageStatus,"/","/ ");
	MortgageStatus=compbl(MortgageStatus);


		*D�BUT DE LA QUESTION 12;
	If HomeValue=9999999 then HomeValue=.;
	If HHIncome<0 then HHIncome=HHIncome*(-1);
RUN;

PROC UNIVARIATE data=data3;
	var HomeValue HHIncome;
	histogram HomeValue HHIncome;
	class Ownership;
	Where Ownership= "Owned";
Run;

*QUESTION 13: Cr�ation de la variable MortgagePyamentCat;

*Afin de r�pondre � cette question en modifiant les variables tout en utilisant data3, je vais recopier les �tapes 
	pr�c�dentes en lien avec la table de donn�es data3 puis y ajouter le code pour la question 12;

DATA data3;
	set data2;
	MortgagePaymentC = tranwrd(MortgagePaymentC, "O", "0");
	MortgagePayment = input(MortgagePaymentC, dollar20.);
	If MortgagePayment<0 then MortgagePayment=MortgagePayment*(-1);
	city=compbl(city);
	If city="Not in identifiable city (or size group" then city="Not in identifiable city (or size group)";
	Ownership=propcase(ownership);
	MortgageStatus=tranwrd(MortgageStatus,"\","/");
	MortgageStatus=tranwrd(MortgageStatus,"-","/");
	MortgageStatus=tranwrd(MortgageStatus,"/","/ ");
	MortgageStatus=compbl(MortgageStatus);
	If HomeValue=9999999 then HomeValue=.;
	If HHIncome<0 then HHIncome=HHIncome*(-1);


		*D�BUT DE LA QUESTION 13;
	If MortgagePayment<=0 then MortgagePaymentCat=1;
	Else if MortgagePayment<=350 then MortgagePaymentCat=2;
	Else If MortgagePayment<=1000 then MortgagePaymentCat=3;
	Else If MortgagePayment<=1600 then MortgagePaymentCat=4;
	Else If MortgagePayment>1600 then MortgagePaymentCat=5;

RUN;

*Pour tester la cr�ation de MortgagePyamentCat;
PROC PRINT data=data3 (obs=30) label;
	ID NO;
RUN;

*Suite de la question 13;
PROC FORMAT;
	value $metro 
		0="Not identifiable"
		1="Not in Metro Area"
		2="Metro, Inside City"
		3="Metro, Outside City"
		4="Metro, City Status Unknown";
RUN;

PROC FORMAT;
	value MortgagePaymentCat
		1="None"
		2="$350 and below"
		3="$351 to $1000"
		4="$1001 to $1600"
		5="Over $1600";
RUN;

PROC TABULATE data=data3;
	class MortgagePaymentCat Metro;
	table MortgagePaymentCat, Metro Metro*colpctn;
	Where Ownership= "Owned";
	format metro $metro.;
	format MortgagePaymentCat MortgagePaymentCat.;
RUN;

*R�PONSE QUESTION 13: Parmi les r�sidences situ�es en ville, la proportion de r�sidences
					  pour lesquelles les paiements hypoth�caires des propri�taires exc�dent 1600$ est de: 12,40%;

*QUESTION 14: Diagramme en b�tons;

PROC SGPLOT data=data3;
	title "R�partition en pourcentage des diff�rentes cat�gories de paiements hypoth�caires";
	hbar MortgagePaymentCat /stat = percent;
	format MortgagePaymentCat MortgagePaymentCat.;
RUN;

ODS PDF CLOSE;
