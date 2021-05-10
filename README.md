# asmMD
A set of functions for molecular dynamics built in x86-64



## Calling Conventions
Functions follow Microsoft `_stdcall` calling conventions. All arguments are passed via stack; callee cleans up the arguments.
Register clobbers: `rax` = return value, if there is one
Preserves all other registers (standard and XMM), but certainly don't rely on it!!



## How to Use


### Windows

#### C/C++
Copy `asmMD.dll`, `asmMD.lib`, and `asmMD.h` files to your project directory. In your project configurations, add the path of the directory `asmMD.h` to the additional includes list. In the linker settings, add the path of the directory containing `asmMD.lib` to additional library directories list, and `asmMD.lib` to additional dependencies under input settings. Finally, when running your built program, make sure that the library `asmMD.dll` itself is in the same directory.


### Linux
Not currently supported because this version uses `kernel32`'s `GlobalAlloc()` and `GlobalFree()`, which is obviously only applicable to Windows! TODO: Switch memory allocation to `malloc()` and `free()` as part of Linux's C standard library.


### Platform-Independent

#### Python
Import the library with `ctypes`; for examaple, using `asmMD = ctypes.DLL("C:\\path\\to\\DLL\\asmMD.dll")`. Then just use the functions within as usual, making sure that Python datatypes passed are compatible with the function signature in `asmMD.h`. For instance, to initialize a 3D box, use the following:

```python
import ctypes
asmMD = ctypes.DLL("C:\\path\\to\\DLL\\asmMD.dll")

nPart = 1000
density = (ctypes.c_double * 1)(0.9)
L = (ctypes.c_double * 1)()
coords = (ctypes.c_double * 4 * nPart)()
asmMD.init3DGrid(nPart, density, L, coords)
```

The length of the box (which is determined by the number of particles and density) will be returned in `L` (in Python, access this using `L[0]`). The coordinates, likewise, will be returned in `coords`. So, the x-coordinate of the 100th particle is accessed with `coords[99][0]`. Note that the coordinate grid should have size _four_ times the number of particles, even though theoretically, only three coordinates per particle are required. This is for computational efficiency.



## Numerical Uncertainty
All functions follow the IEEE-754 standard for 64-bit doubles. The machine epsilon (relative error ratio bound) for this representation is `2.2E-16`. However, with multiple successive floating point operations, this error accumulates; in the worst case, at a rate of the machine epsilon per FLOP.
