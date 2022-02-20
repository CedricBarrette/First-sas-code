ODS PDF FILE = "C:\SAS\TI2\Barrette_TI2_Partie2.pdf";

TITLE "MATH20605 – Travail individuel 2 – Partie 2 – Cédric Barrette";

libname T02 "C:\SAS\TI2\Données";

*RAPPEL DE LA PARTIE 1;
DATA data2;
	infile "C:\SAS\TI2\Données\Donnees2005.txt" DLM='09'x DSD;
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
	If MortgagePayment<=0 then MortgagePaymentCat=1;
	Else if MortgagePayment<=350 then MortgagePaymentCat=2;
	Else If MortgagePayment<=1000 then MortgagePaymentCat=3;
	Else If MortgagePayment<=1600 then MortgagePaymentCat=4;
	Else If MortgagePayment>1600 then MortgagePaymentCat=5;

RUN;

PROC CONTENTS data=data3 order=varnum;
Run;
**Fin du rappel de la partie 1 du devoir;


														*DÉBUT DE LA PARTIE 2 DU DEVOIR;

*QUESTION 15: Exploration des nouvelles tables de données SAS;
PROC CONTENTS data=T02.Donnees2010 order=varnum;
RUN;

PROC CONTENTS data=T02.Donnees2015 order=varnum;
RUN;

*RÉPONSE QUESTION 15: La table de données "Données2010" contient 13 101 observations alors que la table "Données2015" en contient 13 889.;



*QUESTION 16: Vérification des doublons et tri des tables de données;

* le nom de la variable qui donne les numéros d'identification varient selon les tables de données;
	*2005: NO; 
	*2010: serial; 
	*2015: serial;

PROC SORT data=data3 out=donnees2005 noduprec dupout=doublons2005;
	By NO;
RUN;

PROC SORT data=T02.Donnees2010 out=donnees2010 noduprec dupout=doublons2010;
	By SERIAL;
RUN;

PROC SORT data=T02.Donnees2015 out=donnees2015 noduprec dupout=doublons2015;
	By SERIAL;
RUN;

*Vérification des doublons:;
PROC PRINT data=doublons2005 (obs=15);
RUN;

PROC CONTENTS data=doublons2005;
RUN;

PROC PRINT data=doublons2010 (obs=15);
RUN;

PROC CONTENTS data=doublons2010;
RUN;

PROC PRINT data=doublons2015 (obs=15);
RUN;

PROC CONTENTS data=doublons2015;
RUN;


*RÉPONSE QUESTION 16: Seulement trois doublons ont été retirés dans la table Données2005 et aucun dans les deux autre tables.
					  Le numéro d'identification de ces observations était: 1963Alabama, 1964Alabama et 1965Alabama.;




*QUESTION 17: Création d’un identifiant unique;
DATA donnees2005;
	Set donnees2005;
	SERIALC = put(No, $20.);
	Drop No;
RUN;

DATA donnees2010;
	Set donnees2010;
	SERIALC = put(SERIAL, $20.);
	Drop SERIAL;
RUN;

DATA donnees2015;
	Set donnees2015;
	SERIALC = put(SERIAL, $20.);
	Drop SERIAL;
RUN;
*La fonction PROC CONTENTS a été utilisées pour valider la création des variables, mais pour alléger le rapport elle n'est plus dans mon code.


*QUESTION 18: Concaténation des tables;

*Pour permettre la concaténation, les variables Metro et CountyFips dans les tables donnees2010 et donees2015 devront être converties
	en variables alphanumériques comme dans la table donees2005;

DATA donnees2010;
	Set donnees2010;
	Metro2 = put(Metro, 8.);
	CountyFips2 = put(CountyFips, 8.);
	drop Metro CountyFips;
	rename Metro2=Metro;
	rename CountyFips2=CountyFips;
RUN;

DATA donnees2015;
	Set donnees2015;
	Metro2=put(Metro, 8.);
	CountyFips2=put(CountyFips, 8.);
	drop Metro CountyFips;
	rename Metro2=Metro;
	rename CountyFips2=CountyFips;
RUN; 

*La concaténation vertical est faite grâce à l'énoncé "Set" et l'option "IN" permet de créer la variable temporaire 
	qui suit l'origine des données;

DATA donneesALL;
	Set donnees2005 (in=D2005) donnees2010 (in=D2010) donnees2015 (in=D2015);
	If D2005=1 then ANNEE="2005";
	If D2010=1 then ANNEE="2010";
	If D2015=1 then ANNEE="2015";
RUN;

PROC FREQ data=donneesALL;
	Tables ANNEE;
RUN;

*RÉPONSE QUESTION 18: 97,72% des observations proviennent de la table de de données de 2005.



*QUESTION 19: Rapport sur le Revenu familial;

	*Tout comme lors de la partie 1 du travail, on peut assumer que les signes négatifs pour le revenus familiaux dans les 
		tables de données de 2010 et 2015 sont des erreurs. 
		Je vais donc convertir ces valeurs négatives en valeurs positives pour que le tableau offre une analyse plus intéressante.;

DATA donneesALL;
	Set donneesALL;
	If HHIncome<0 then HHIncome=HHIncome*(-1);
RUN;


PROC TABULATE data=donneesALL;
	Where Ownership NE "N/A";
		*Cet énoncé était nécessaire pour n'avoir que les valeurs de "ownership" attendues.;
	Class Ownership Annee;
	Var HHIncome;
	Table Ownership=" ", 
		Annee=" "*(MEAN*f=dollar14.2 MEDIAN*f=dollar14.2 MIN*f=dollar14.2 MAX*f=dollar14.2 N*f=nlnum8.)*HHINCOME=" "
		all*(MEAN*f=dollar14.2 MEDIAN*f=dollar14.2 MIN*f=dollar14.2 MAX*f=dollar14.2 N*f=nlnum8.)*HHINCOME=" " / box="Revenu Familial";
			*le format monétaire a été ajouté à toutes les statistiques descriptives sauf "N";
			*le format "nlnum" a été utilisé pour "N" pour séparer les milliers avec un espace;
RUN;

ODS PDF CLOSE;
