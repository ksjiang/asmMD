#pragma once

extern "C" int _stdcall LibMain();
extern "C" void _stdcall LJc(double* rij_, double* rc, double* Fij_);
extern "C" void _stdcall LJuc(double* rij_, double* rc, double* U);
extern "C" void _stdcall LJinit(double* L);
extern "C" void _stdcall LJforceEval(int nPart, double* X_, double* L, double* F_);
extern "C" void _stdcall LJenergyEval(int nPart, double* X_, double* L, double* U);
extern "C" void _stdcall LJenergyDiff(int nPart, double* X_, double* L, int i, double* deltaU);
extern "C" void _stdcall init3DGrid(int nPart, double* dens, double* L, double* grid);