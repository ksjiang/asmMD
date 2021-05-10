// eval.cpp : main project file.

#include "stdafx.h"
#include "stdlib.h"
#include "stdio.h"
#include "asmMD.h"

using namespace System;


int main()
{
	printf("Hello there, friend!\n");
	// create a buffer from which to call initBox
	int nPart = 125;
	double dens = 0.85;
	double L;
	double* grid1 = (double*) malloc(8 * 4 * nPart);
	init3DGrid(nPart, &dens, &L, grid1);

	// test random coordinates
	free(grid1);
	double grid2[4 * 125] = {0.527693187,0.527959105,0.527834392,0,1.583408375,0.527998621,0.527947251,0,2.639144205,0.527872906,0.527783556,0,3.694715194,0.527863105,0.527798833,0,4.750449064,0.527885391,0.527768829,0,0.52778948,1.583742923,0.527506939,0,1.583392614,1.583314436,0.528135621,0,2.639134137,1.583738684,0.527864477,0,3.694847773,1.583327939,0.52768182,0,4.750495621,1.583408805,0.52814009,0,0.52767048,2.639369937,0.527900417,0,1.58345466,2.639016005,0.52772931,0,2.639072586,2.638969947,0.528060896,0,3.694719927,2.638989329,0.5278409,0,4.750508887,2.63896509,0.527769194,0,0.527872688,3.695021863,0.527787207,0,1.583638903,3.694597931,0.527779153,0,2.63919667,3.694481269,0.527871195,0,3.694747775,3.694671924,0.52800991,0,4.75054891,3.694724217,0.5277847,0,0.527626887,4.750347675,0.52803768,0,1.583797044,4.750612068,0.527730896,0,2.639221683,4.750422144,0.527735581,0,3.694982968,4.750792174,0.527878642,0,4.750649357,4.750399736,0.52779933,0,0.527787756,0.528026072,1.583440318,0,1.583507808,0.527920734,1.583442883,0,2.639036162,0.527800355,1.583400939,0,3.694759449,0.527960123,1.583489355,0,4.750625783,0.527633802,1.583491406,0,0.527655803,1.58349781,1.583334317,0,1.583551316,1.58362088,1.583443288,0,2.639195626,1.583624851,1.583601201,0,3.69484555,1.583258152,1.583440153,0,4.750215444,1.583445013,1.583634267,0,0.527906306,2.639520994,1.583477475,0,1.583607608,2.639182794,1.58336884,0,2.639176134,2.639083745,1.583371082,0,3.694750806,2.639137673,1.583891334,0,4.750428792,2.639065998,1.583400031,0,0.527836997,3.695001578,1.583336235,0,1.583146233,3.694821631,1.583651003,0,2.63881928,3.694946583,1.583688101,0,3.69486419,3.694548194,1.583508542,0,4.750588293,3.694955505,1.583609067,0,0.527944185,4.75066552,1.58333077,0,1.583655317,4.750244948,1.583513415,0,2.639219269,4.750661186,1.583362876,0,3.694865308,4.75069613,1.583563065,0,4.750616201,4.750496683,1.583418753,0,0.527984131,0.527920914,2.63933162,0,1.583438179,0.527840531,2.639325408,0,2.639016192,0.527915141,2.639241924,0,3.6950653,0.528119717,2.63936384,0,4.750341748,0.527593775,2.638977039,0,0.527942927,1.58342245,2.639016412,0,1.58347693,1.583484517,2.638974132,0,2.639175215,1.583340716,2.639050913,0,3.694970504,1.583421646,2.63907089,0,4.750724816,1.583649684,2.639236262,0,0.527882694,2.63903451,2.639073401,0,1.583618962,2.639175719,2.63909386,0,2.639473707,2.639080903,2.639075323,0,3.694766591,2.638818789,2.639249151,0,4.750660227,2.639245277,2.638997479,0,0.527655655,3.694961352,2.639079645,0,1.583672791,3.694668641,2.639251119,0,2.639030996,3.694756143,2.639073955,0,3.695021493,3.694950952,2.639201125,0,4.750693825,3.694694352,2.638922521,0,0.527900824,4.750510168,2.639182749,0,1.583369329,4.75060461,2.639245591,0,2.638978639,4.75049487,2.639349192,0,3.694825263,4.750796882,2.639183305,0,4.750469997,4.750314308,2.639175842,0,0.527924353,0.528107849,3.694721768,0,1.58347371,0.527843853,3.694888939,0,2.63923433,0.528048482,3.694943731,0,3.694757081,0.528183192,3.694759653,0,4.750567917,0.528050281,3.69506762,0,0.527689988,1.583474672,3.694727075,0,1.583484045,1.583477122,3.6946543,0,2.639226873,1.58356105,3.69481161,0,3.694773709,1.583450391,3.694516603,0,4.75033473,1.583366852,3.694862119,0,0.527869737,2.639105715,3.694925221,0,1.5835412,2.639291489,3.694834225,0,2.639185356,2.639257532,3.694844475,0,3.694994872,2.639076176,3.694907016,0,4.750484065,2.639230341,3.694718032,0,0.527953664,3.694482892,3.694738975,0,1.583820164,3.695075664,3.694850067,0,2.639024351,3.694749048,3.694740231,0,3.694920608,3.695074163,3.694820233,0,4.750498234,3.69481092,3.695022268,0,0.527796394,4.750547358,3.694693637,0,1.58361178,4.750319709,3.694906693,0,2.639034821,4.750956789,3.694876431,0,3.694720309,4.750472054,3.695026112,0,4.750508248,4.750273414,3.694957479,0,0.527808212,0.527695187,4.750711939,0,1.583533099,0.527676983,4.750748369,0,2.639333614,0.527640739,4.750540478,0,3.694952729,0.527721741,4.75056646,0,4.750488319,0.527801432,4.750355893,0,0.528033571,1.5835699,4.75050129,0,1.583533615,1.58370699,4.750473707,0,2.639070854,1.58355847,4.750639345,0,3.694782719,1.583312462,4.750257127,0,4.750340766,1.583723725,4.750651608,0,0.527666414,2.63913944,4.750552522,0,1.583407872,2.639215138,4.750402588,0,2.639009299,2.639026859,4.750596506,0,3.694775745,2.639110922,4.750501771,0,4.750363595,2.6390883,4.750602889,0,0.52798216,3.694829704,4.750540725,0,1.583391366,3.694763918,4.750447893,0,2.63924799,3.694797982,4.750674352,0,3.694689706,3.694878226,4.750412933,0,4.750509814,3.694851772,4.7501941,0,0.527806847,4.750400195,4.750794318,0,1.583657054,4.750477191,4.750422596,0,2.639139885,4.750536347,4.7506562,0,3.694825599,4.75062377,4.750463811,0,4.750674484,4.750436349,4.750345332,0};
	double* force = (double*) malloc(8 * 4 * nPart);
//	LJforceEval(nPart, grid2, &L, force);

	nPart = 500;
	dens = 0.5;
	double U;
	double* grid3 = (double*) malloc(8 * 4 * nPart);
	init3DGrid(nPart, &dens, &L, grid3);
	LJenergyEval(nPart, grid3, &L, &U);
	printf("Energy: %0.10e\n", U);

	double Utot = 0.0;
	for (int i = 0; i < nPart; i++) {
//		LJenergyDiff(nPart, grid3, &L, i, &U);
//		Utot += U;
//		printf("Energy [%d]: %0.10e, %0.10e\n", i, Utot, U);
		LJenergyEval(nPart, grid3, &L, &U);
		printf("Energy: %0.10e\n", U);
	}

	return 0x45;
}