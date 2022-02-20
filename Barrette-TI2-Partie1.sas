ODS PDF FILE = "C:\SAS\TI2\Barrette_TI2_Partie1.pdf";

TITLE "MATH20605 – Travail individuel 2 – Partie 1 – Cédric Barrette";

*QUESTION 1: Lecture de données brutes;
libname bibli2 "C:\SAS\TI2\Données";

DATA bibli2.data1;
	infile "C:\SAS\TI2\Données\Donnees2005.txt" DLM='09'x DSD;
		* Les caractères "'09'x" sont utilisés pour représenté les espaces de type "tab";
		* le DSD est utilisé pour identifier les valeurs manquantes;

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
		NO = "Identification de la propriété"
		CityPop = "Population de la ville"
		Metro = "Région métropolitaine"
		CountyFips = "Code"
		Ownership = "Propriété"
		MortgageStatus = "Situation hypothécaire"
		HHincome = "Revenu familial"
		HomeValue = "Valeur de la propriété"
		City = "Ville"
		MortgagePayment = "Paiement hypothécaire"
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


*QUESTION 2: Rapport sur les 30 premières observations;
PROC PRINT data=bibli2.data1 (obs=30) label;
	ID NO;
RUN;

*QUESTION 3: Vérification des valeurs de la variable MortgagePayment;
PROC MEANS data=bibli2.data1 maxdec=1 max min n nmiss q1 median q3 mean;
	var MortgagePayment;
RUN;

	*RÉPONSE QUESTION3: La valeur minimale est de -1500$. Considérant que cette variable représente le montant qui doit 
						être versé à la banque pour l'hypothèque, un montant négatif n'est pas plausible non. 

*QUESTION 4: Lecture des données brutes de MortgagePayment en format texte;

DATA data2;
	infile "C:\SAS\TI2\Données\Donnees2005.txt" DLM='09'x DSD;
		*MortgagePaymentC est identifiée comme une variable alphanumérique (texte) grâce au "$";
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
			*maintenant, la conversion de la variable MortgagePayment en format texte vers le format numérique;
		MortgagePayment = input(MortgagePaymentC, dollar20.);

	label
		NO = "Identification de la propriété"
		CityPop = "Population de la ville"
		Metro = "Région métropolitaine"
		CountyFips = "Code"
		Ownership = "Propriété"
		MortgageStatus = "Situation hypothécaire"
		HHincome = "Revenu familial"
		HomeValue = "Valeur de la propriété"
		City = "Ville"
		MortgagePayment = "Paiement hypothécaire"
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

*RÉPONSE QUESTION 4: Comme on peut le voir grâce à l'impression, lorsque MortgagePayment affiche une valeur manquante,
					 les valeurs MortgagePaymentC correspondantes sont composées de O plutôt que de 0 (zéro) ce qui semble
					 causé une erreur lorsque SAS essaye de lire ces caractères en format numérique;

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
	*Afin de répondre à cette question en modifiant les variables tout en utilisant data3, je vais recopier les étapes 
	précédentes en lien avec la table de données data3 puis y ajouter le code pour la question 7;

DATA data3;
	set data2;
	MortgagePaymentC = tranwrd(MortgagePaymentC, "O", "0");
	MortgagePayment = input(MortgagePaymentC, dollar20.);
	If MortgagePayment<0 then MortgagePayment=MortgagePayment*(-1);


		*DÉBUT DE LA QUESTION 7;
	city=compbl(city);
	If city="Not in identifiable city (or size group" then city="Not in identifiable city (or size group)";
	Ownership=propcase(ownership);
	MortgageStatus=tranwrd(MortgageStatus,"\","/");
	MortgageStatus=tranwrd(MortgageStatus,"-","/");
		*à l'aide des deux énoncés suivants, j'ajoute un espace à toutes les barres obliques, puis utilise la fonction
		"compbl" pour enlever les double espaces;
	MortgageStatus=tranwrd(MortgageStatus,"/","/ ");
	MortgageStatus=compbl(MortgageStatus);
RUN;

*QUESTION 8: Vérification des valeurs des variables de type texte : Ownership, MortgageStatus et City;

PROC FREQ data=data3 order=freq;
	tables Ownership MortgageStatus City;
RUN;

*RÉPONSE QUESTION 8: 
	City: La ville la plus représentée dans la table de données est "New York" qui se trouve dans l'état de New York (NY).
	Ownership: le pourcentage de résidences occupées par des propriétaires est de 73,83%;

*QUESTION 9: Création d’un format pour l’affichage des étiquettes de valeurs de la variable Metro;

PROC FORMAT;
		*La variable "Metro" est alphanumérique";
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

*RÉPONSE QUESTION 10: Effectivement, les résultats me semblent plausibles;

*QUESTION 11: Vérification des valeurs pour les variables numériques HomeValue et HHincome;

PROC UNIVARIATE data=data3 noprint;
	var HomeValue HHIncome;
	histogram HomeValue HHIncome;
	class Ownership;
Run;

*RÉPONSE QUESTION 11: Pour simplifier l'impression de la procédure Univariate et pour n'avoir que les histogrammes des deux variables,
					  l'option "noprint" a été utilisée, mais pour permettre de répondre à cette question avec plus d'exactitude,
					  j'ai enlevée cette option et j'ai été en mesure de lire les réponses dans les rapport produit.

					  Le revenu familial le plus faible rapportée par un propriétaire: -29 997$
					  Le revenu familial le plus faible rapportée par un locataire: -19 998$
					  La valeur de la résidence la plus dispendieuse: 9 999 999$ (pour des locataires d'ailleurs);

*QUESTION 12: Correction des valeurs pour les variables numériques HomeValue et HHIncome;

	*Afin de répondre à cette question en modifiant les variables tout en utilisant data3, je vais recopier les étapes 
	précédentes en lien avec la table de données data3 puis y ajouter le code pour la question 12;

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


		*DÉBUT DE LA QUESTION 12;
	If HomeValue=9999999 then HomeValue=.;
	If HHIncome<0 then HHIncome=HHIncome*(-1);
RUN;

PROC UNIVARIATE data=data3;
	var HomeValue HHIncome;
	histogram HomeValue HHIncome;
	class Ownership;
	Where Ownership= "Owned";
Run;

*QUESTION 13: Création de la variable MortgagePyamentCat;

*Afin de répondre à cette question en modifiant les variables tout en utilisant data3, je vais recopier les étapes 
	précédentes en lien avec la table de données data3 puis y ajouter le code pour la question 12;

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


		*DÉBUT DE LA QUESTION 13;
	If MortgagePayment<=0 then MortgagePaymentCat=1;
	Else if MortgagePayment<=350 then MortgagePaymentCat=2;
	Else If MortgagePayment<=1000 then MortgagePaymentCat=3;
	Else If MortgagePayment<=1600 then MortgagePaymentCat=4;
	Else If MortgagePayment>1600 then MortgagePaymentCat=5;

RUN;

*Pour tester la création de MortgagePyamentCat;
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

*RÉPONSE QUESTION 13: Parmi les résidences situées en ville, la proportion de résidences
					  pour lesquelles les paiements hypothécaires des propriétaires excèdent 1600$ est de: 12,40%;

*QUESTION 14: Diagramme en bâtons;

PROC SGPLOT data=data3;
	title "Répartition en pourcentage des différentes catégories de paiements hypothécaires";
	hbar MortgagePaymentCat /stat = percent;
	format MortgagePaymentCat MortgagePaymentCat.;
RUN;

ODS PDF CLOSE;
