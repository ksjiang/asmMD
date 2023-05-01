#pragma once

#define R_C 2.5

extern "C" int _stdcall LibMain();
extern "C" void _stdcall LJc(double* rij_, double* rc, double* Fij_);
extern "C" void _stdcall LJuc(double* rij_, double* rc, double* U);
extern "C" void _stdcall LJinit(double* L);
extern "C" void _stdcall LJforceEval(int nPart, double* X_, double* L, double* F_);
extern "C" void _stdcall LJenergyEval(int nPart, double* X_, double* L, double* U);
extern "C" void _stdcall LJenergyDiff(int nPart, double* X_, double* L, int i, double* deltaU);
extern "C" void _stdcall LJpressureEval(int nPart, double* X_, double* L, double* Pxyz_);
extern "C" void _stdcall LJstep(int nPart, double* X_, double* BOX, double* V_, double* F_, double* delT);
extern "C" void _stdcall init3DGrid(int nPart, double* dens, double* L, double* grid);
extern "C" void _stdcall pbc3d(int nPart, double* X_, double* BOX, double* L);
extern "C" void _stdcall dblBufferVec4Cpy(double* buf1, double* buf2, int nPart);
extern "C" void _stdcall dblBufferVec4Mul(double* buf, double* vec, int nPart);
extern "C" void _stdcall dblBufferVec4Add(double* buf, double* vec, int nPart);
extern "C" void _stdcall dblBufferVec4Sum(double* buf, int nPart, double* sum);
extern "C" void _stdcall dblBuffer2Vec4Sum(double* buf1, double* buf2, int nPart, double* sum);
extern "C" void _stdcall dblBuffer2Vec3Dot(double* buf1, double* buf2, int nPart, double* dot);