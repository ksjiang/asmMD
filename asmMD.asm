.686p
.model flat, stdcall
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\kernel32.lib
.xmm




.data
; constants
NSIX				REAL8			-6.0f
NSEVENHALF			REAL8			-3.5f
NTHREE				REAL8			-3.0f
NUNITY				REAL8			-1.0f
NHALF				REAL8			-0.5f
THIRD				REAL8			0.333333333333333333333f				; :)
HALF 				REAL8 			0.5f
THREEHALF 			REAL8 			1.5f
PI					REAL8			3.141592653589793238463f
FORTYEIGHT			REAL8			48.0f
MAGIC 				dq 				5fe6eb50c7b537a9h

; mutables
LJisset				dd				0
LJn					dd				0
LJLint				REAL8			0.0f
LJrc				REAL8			2.5f
LJdn				REAL8			0.0f




.code
LibMain proc h:DWORD, r:DWORD, u:DWORD
	mov eax, 1
	ret
LibMain Endp



LJc proc rij_:DWORD, rc:DWORD, Fij_:DWORD
	sub esp, 90h
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	movdqu [ebp - 40h], xmm3
	mov dword ptr [ebp - 44h], ebx
	
	; zero out the force
	mov eax, Fij_
	xorpd xmm0, xmm0
	movsd qword ptr [eax], xmm0
	movsd qword ptr [eax + 8], xmm0
	movsd qword ptr [eax + 10h], xmm0
	
	; get radius norm
	mov eax, rij_
	movsd xmm0, qword ptr [eax]
	mulsd xmm0, xmm0
	movsd xmm1, qword ptr [eax + 8]
	mulsd xmm1, xmm1
	addsd xmm0, xmm1
	movsd xmm1, qword ptr [eax + 10h]
	mulsd xmm1, xmm1
	addsd xmm0, xmm1					;xmm0 = rij^2
	mov eax, rc
	movsd xmm3, qword ptr [eax]
	mulsd xmm3, xmm3					;xmm3 = rc^2
	ucomisd xmm0, xmm3
	ja LJc2								;if rij^2 > rc^2 => rij > rc, return a force of 0
	
LJc1:
;COMMENT @
	; this is an ok (fast) way to calculate the force, but there is a slight round-off error
	; which may or may not be important
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm1, [NHALF]
	movdqu [eax], xmm1
	push eax
	lea eax, [ebp - 60h]
	movdqu [eax], xmm0
	push eax
	call pow
	movsd xmm0, qword ptr [ebp - 80h]	;xmm0 = 1 / rij
	movsd xmm1, xmm0
	mulsd xmm1, xmm1
	mulsd xmm1, xmm0
	mulsd xmm1, xmm1					;xmm1 = 1 / rij^6
	movsd xmm2, xmm0
	mulsd xmm2, xmm1					;xmm2 = 1 / rij^7
	movsd xmm3, qword ptr [HALF]
	subsd xmm1, xmm3
	movsd xmm3, qword ptr [FORTYEIGHT]
	mulsd xmm1, xmm3
	mulsd xmm2, xmm1					;xmm2 = Fij = 48 * (1 / rij^7) * (1 / rij^6 - 0.5)
;@
	
COMMENT @
	; this will give a more accurate result, but is slower
	; first calculate 1 / rij^7
	movsd qword ptr [ebp - 90h], xmm0
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm1, [NSEVENHALF]
	movsd qword ptr [eax], xmm1
	push eax
	lea eax, [ebp - 60h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm2, qword ptr [ebp - 80h]		;store in xmm2
	; next compute 2 / rij^6 - 1
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm0, [NTHREE]
	movsd qword ptr [eax], xmm0
	push eax
	lea eax, [ebp - 60h]
	movsd xmm0, qword ptr [ebp - 90h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm3, qword ptr [ebp - 80h]
	movsd xmm0, xmm3
	addsd xmm3, xmm0
	mov ebx, 1
	cvtsi2sd xmm0, ebx
	subsd xmm3, xmm0						;store in xmm3
	mulsd xmm2, xmm3						;multiply them (result in xmm2)
	mov ebx, 24
	cvtsi2sd xmm0, ebx
	mulsd xmm2, xmm0						;scale by 24 to get magnitude (done)
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm1, [NHALF]
	movsd qword ptr [eax], xmm1
	push eax
	lea eax, [ebp - 60h]
	movsd xmm0, qword ptr [ebp - 90h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm0, qword ptr [ebp - 80h]		;xmm0 = norm
@
	
	; store the force
	mov ebx, rij_
	mov eax, Fij_
	movsd xmm1, qword ptr [ebx]
	mulsd xmm1, xmm0
	mulsd xmm1, xmm2
	movsd qword ptr [eax], xmm1
	movsd xmm1, qword ptr [ebx + 8]
	mulsd xmm1, xmm0
	mulsd xmm1, xmm2
	movsd qword ptr [eax + 8], xmm1
	movsd xmm1, qword ptr [ebx + 10h]
	mulsd xmm1, xmm0
	mulsd xmm1, xmm2
	movsd qword ptr [eax + 10h], xmm1
	
LJc2:
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	movdqu xmm3, [ebp - 40h]
	mov ebx, dword ptr [ebp - 44h]
	add esp, 90h
	ret
LJc endp



LJuc proc rij_:DWORD, rc:DWORD, U:DWORD
	sub esp, 90h
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	movdqu [ebp - 40h], xmm3
	mov dword ptr [ebp - 44h], ebx
	
	; zero out the energy
	mov eax, U
	xorpd xmm0, xmm0
	movsd qword ptr [eax], xmm0
	
	; get radius norm
	mov eax, rij_
	movsd xmm0, qword ptr [eax]
	mulsd xmm0, xmm0
	movsd xmm1, qword ptr [eax + 8]
	mulsd xmm1, xmm1
	addsd xmm0, xmm1
	movsd xmm1, qword ptr [eax + 10h]
	mulsd xmm1, xmm1
	addsd xmm0, xmm1					;xmm0 = rij^2
	mov eax, rc
	movsd xmm3, qword ptr [eax]
	mulsd xmm3, xmm3					;xmm3 = rc^2
	ucomisd xmm0, xmm3
	ja LJuc2							;if rij^2 > rc^2 => rij > rc, return an interaction energy of 0
	
LJuc1:
	movsd qword ptr [ebp - 90h], xmm0
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm0, [NTHREE]
	movsd qword ptr [eax], xmm0
	push eax
	lea eax, [ebp - 60h]
	movsd xmm0, qword ptr [ebp - 90h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm0, qword ptr [ebp - 80h]
	movsd xmm1, xmm0
	mov eax, 1
	cvtsi2sd xmm2, eax
	subsd xmm1, xmm2					;xmm1 = 1 / r^6 - 1
	mulsd xmm0, xmm1					;xmm0 = 1 / r^12 - 1 / r^6
COMMENT @
	; calculate the CUTOFF interaction potential (needs to be subtracted)
	lea eax, [ebp - 80h]
	push eax
	lea eax, [ebp - 70h]
	movsd xmm1, [NSIX]
	movsd qword ptr [eax], xmm1
	push eax
	lea eax, [ebp - 60h]
	mov eax, dword ptr [rc]
	movsd xmm1, qword ptr [eax]
	movsd qword ptr [eax], xmm1
	push eax
	call pow
	movsd xmm1, qword ptr [ebp - 80h]
	movsd xmm2, xmm1
	mov eax, 1
	cvtsi2sd xmm3, eax
	subsd xmm2, xmm3					;xmm2 = 1 / rc^6 - 1
	mulsd xmm1, xmm2					;xmm1 = 1 / rc^12 - 1 / rc^6
	subsd xmm0, xmm1
@
	mov eax, 4							;finally, multiply this difference by 4
	cvtsi2sd xmm1, eax
	mulsd xmm0, xmm1
	
	;store the energy
	mov eax, dword ptr [U]
	movsd qword ptr [eax], xmm0
	
LJuc2:
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	movdqu xmm3, [ebp - 40h]
	mov ebx, dword ptr [ebp - 44h]
	add esp, 90h
	ret
LJuc endp



LJinit proc L:DWORD
	; initialize the LJ cutoff parameters and cell list
	mov eax, dword ptr [L]
	movsd xmm0, qword ptr [eax]
	movsd qword ptr [LJLint], xmm0		;Lint = L
	movsd xmm2, xmm0
	movsd xmm1, qword ptr [LJrc]
	divsd xmm0, xmm1
	cvttsd2si eax, xmm0					;eax = floor(Lint / rc) --> cvtTsd2si to truncate rather than round
	cmp eax, 0
	mov ebx, 1
	cmova ebx, eax
	mov dword ptr [LJn], ebx			;n = max(1, floor(Lint / rc))
	cvtsi2sd xmm0, eax
	divsd xmm2, xmm0
	movsd qword ptr [LJdn], xmm2		;d_n = Lint / n
	mov dword ptr [LJisset], 1			;isset = true
	ret
LJinit endp



LJforceEval proc nPart:DWORD, X_:DWORD, L:DWORD, F_:DWORD
	sub esp, 90h						;memory corruption much?
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	mov dword ptr [ebp - 34h], ebx
	mov dword ptr [ebp - 38h], ecx
	mov dword ptr [ebp - 3ch], edx
	mov dword ptr [ebp - 40h], esi
	mov dword ptr [ebp - 44h], edi
	
	; start
	mov eax, [LJisset]
	test eax, eax
	jnz LJforceEval2					;params already initialized, go evaluate the forces
	
	; initialize
	push dword ptr [L]
	call LJinit
	
LJforceEval2:
	mov eax, nPart
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 50h], eax		;cellmap
	; commenting out - caller provides this
;	mov eax, nPart
;	shl eax, 5
;	invoke GlobalAlloc, 40h, eax
;	mov eax, F_
;	mov dword ptr [eax], eax			;forces
	; even though caller provides this memory, it should be *zeroed out* before use to ensure correctness
	; do this with a simple rep instruction
	mov edi, F_
	xor eax, eax
	mov ecx, nPart
	shl ecx, 3							;number of dwords
	rep stosd							;and done
	mov eax, dword ptr [LJn]
	mov ebx, eax
	imul eax, ebx
	imul eax, ebx
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 54h], eax		;cells
	
	; sort particles into cells
	mov dword ptr [ebp - 58h], 0
LJforceEval3:
	; extract particle coordinates
	mov esi, dword ptr [ebp - 58h]
	shl esi, 5
	add esi, X_
	movsd xmm0, qword ptr [esi]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 5ch], eax		;nx
	movsd xmm0, qword ptr [esi + 8]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 60h], eax		;ny
	movsd xmm0, qword ptr [esi + 10h]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 64h], eax		;nz
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 60h]
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 5ch]
	mov dword ptr [ebp - 8ch], eax		;ecx clobber :(
	mov esi, dword ptr [ebp - 54h]
	lea esi, [esi + 4 * eax]			;traverse the singly-linked list
LJforceEval4:
	mov eax, dword ptr [esi]
	test eax, eax
	jz LJforceEval5
	mov esi, eax
	jmp LJforceEval4
LJforceEval5:
	; allocate. esi is now pointing to last node.
	invoke GlobalAlloc, 40h, 8
	mov dword ptr [esi], eax			;set next of previously last node
	mov ebx, dword ptr [ebp - 58h]
	mov dword ptr [eax + 4], ebx		;append i to cell list
	mov edi, dword ptr [ebp - 50h]
	mov ecx, dword ptr [ebp - 8ch]		;restore ecx!!
	mov dword ptr [edi + 4 * ebx], ecx	;append cell index into cellmap
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	cmp ebx, nPart
	jb LJforceEval3
	; close loop
	
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 80h], eax
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 84h], eax
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 88h], eax
	
	; calculate interactions
	; big outer loop
	mov dword ptr [ebp - 58h], 0
LJforceEval6:
	mov ebx, dword ptr [LJn]
	mov esi, ebx
	imul esi, ebx
	mov ecx, dword ptr [ebp - 58h]
	mov edi, dword ptr [ebp - 50h]
	mov eax, dword ptr [edi + 4 * ecx]
	mov ecx, eax
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 5ch], edx
	mov eax, ecx						;restore
	xor edx, edx
	idiv ebx
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 60h], edx
	mov eax, ecx
	xor edx, edx
	idiv esi
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 64h], edx
	
	; loop over x offsets
	mov dword ptr [ebp - 68h], 0ffffffffh
LJforceEval7:

	; loop over y offsets
	mov dword ptr [ebp - 6ch], 0ffffffffh
LJforceEval8:

	; loop over z offsets
	mov dword ptr [ebp - 70h], 0ffffffffh
LJforceEval9:
	mov ecx, 3
	lea edi, [ebp - 7ch]
	lea esi, [ebp - 64h]
	rep movsd
	mov eax, dword ptr [ebp - 68h]
	add dword ptr [ebp - 74h], eax
	mov eax, dword ptr [ebp - 6ch]
	add dword ptr [ebp - 78h], eax
	mov eax, dword ptr [ebp - 70h]
	add dword ptr [ebp - 7ch], eax
	
	; loop over dimensions, form correction vector
	mov ecx, 8							;clear out the correction vector!
	xor eax, eax
	mov edi, dword ptr [ebp - 80h]
	rep stosd
	mov ecx, 2
	xor edx, edx
	movsd xmm0, qword ptr [LJLint]
	movsd xmm1, qword ptr [NUNITY]
	mulsd xmm1, xmm0					;xmm1 = -Lint
LJforceEval10:
	mov ebx, dword ptr [LJn]
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, 0
	jge LJforceEval11
	; make PBC correction
	add dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm0
	
LJforceEval11:
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, ebx
	jl LJforceEval12
	;make PBC correction
	sub dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm1
	
LJforceEval12:
	inc edx
	dec ecx
	cmp ecx, 0
	jge LJforceEval10
	
	; loop over neighbor cell list
	mov ebx, dword ptr [ebp - 7ch]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 78h]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 74h]
	mov esi, [ebp - 54h]
	lea edi, [esi + 4 * ebx]			;traverse the singly-linked list
	jmp LJforceEval14
LJforceEval13:
	mov edi, eax
	mov ecx, [edi + 4]					;ecx -> particle j
	mov edx, [ebp - 58h]				;edx index of* particle i
	cmp ecx, edx
	jz LJforceEval14					;continue if same particle
	mov eax, dword ptr [ebp - 84h]
	mov esi, ecx						;go to j
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu [eax], xmm0
	movdqu xmm0, [esi + 10h]
	movdqu [eax + 10h], xmm0
	mov esi, edx						;go to i
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	mov esi, dword ptr [ebp - 80h]		;go to corr
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	push [ebp - 88h]
	lea eax, [LJrc]
	push eax
	push dword ptr [ebp - 84h]
	call LJc
	mov eax, dword ptr [ebp - 88h]
	mov esi, edx						;go to i
	shl esi, 5
	add esi, F_
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm0, xmm1
	movdqu [esi], xmm0
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm0, xmm1
	movdqu [esi + 10h], xmm0
LJforceEval14:
	mov eax, dword ptr [edi]
	test eax, eax
	jnz LJforceEval13					;fallthrough if all done
	
LJforceEval15:
	inc dword ptr [ebp - 70h]
	cmp dword ptr [ebp - 70h], 1
	jle LJforceEval9
	; close loop
	inc dword ptr [ebp - 6ch]
	cmp dword ptr [ebp - 6ch], 1
	jle LJforceEval8
	; close loop
	inc dword ptr [ebp - 68h]
	cmp dword ptr [ebp - 68h], 1
	jle LJforceEval7
	; close loop
	
	mov eax, dword ptr [ebp - 58h]
	inc eax
	mov dword ptr [ebp - 58h], eax
	cmp eax, nPart
	jb LJforceEval6
	; close loop
	
	; clean up and exit
	invoke GlobalFree, dword ptr [ebp - 50h]
	invoke GlobalFree, dword ptr [ebp - 80h]
	invoke GlobalFree, dword ptr [ebp - 84h]
	invoke GlobalFree, dword ptr [ebp - 88h]
	
	; need to free all of the elements of the linked list
	mov dword ptr [ebp - 58h], 0
LJforceEval16:
	mov ebx, dword ptr [ebp - 58h]
	mov esi, dword ptr [ebp - 54h]
	lea edi, [esi + 4 * ebx]
	mov esi, dword ptr [edi]
	jmp LJforceEval18
LJforceEval17:
	mov edi, esi
	mov esi, dword ptr [edi]
	invoke GlobalFree, edi
LJforceEval18:
	test esi, esi
	jnz LJforceEval17					;fallthrough if all done
	
LJforceEval19:
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	mov eax, dword ptr [LJn]
	imul eax, eax
	imul eax, dword ptr [LJn]
	cmp ebx, eax
	jb LJforceEval16
	
	; now, free the cell list itself
	invoke GlobalFree, dword ptr [ebp - 54h]
	
	; restore and return
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	mov ebx, dword ptr [ebp - 34h]
	mov ecx, dword ptr [ebp - 38h]
	mov edx, dword ptr [ebp - 3ch]
	mov esi, dword ptr [ebp - 40h]
	mov edi, dword ptr [ebp - 44h]
	add esp, 90h
	ret
LJforceEval endp



LJenergyEval proc nPart:DWORD, X_:DWORD, L:DWORD, U:DWORD
	sub esp, 0b0h						;memory corruption much?
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	mov dword ptr [ebp - 34h], ebx
	mov dword ptr [ebp - 38h], ecx
	mov dword ptr [ebp - 3ch], edx
	mov dword ptr [ebp - 40h], esi
	mov dword ptr [ebp - 44h], edi
	
	; start
	mov eax, [LJisset]
	test eax, eax
	jnz LJenergyEval2					;params already initialized, go evaluate the energy
	
	; initialize
	push dword ptr [L]
	call LJinit
	
LJenergyEval2:
	mov eax, nPart
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 50h], eax		;cellmap
	; zero out the energy
	mov edi, dword ptr [U]
	xorpd xmm0, xmm0
	movsd qword ptr [edi], xmm0
	mov eax, dword ptr [LJn]
	mov ebx, eax
	imul eax, ebx
	imul eax, ebx
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 54h], eax		;cells
	
	; sort particles into cells
	mov dword ptr [ebp - 58h], 0
LJenergyEval3:
	; extract particle coordinates
	mov esi, dword ptr [ebp - 58h]
	shl esi, 5
	add esi, X_
	movsd xmm0, qword ptr [esi]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 5ch], eax		;nx
	movsd xmm0, qword ptr [esi + 8]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 60h], eax		;ny
	movsd xmm0, qword ptr [esi + 10h]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 64h], eax		;nz
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 60h]
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 5ch]
	mov dword ptr [ebp - 90h], eax		;ecx clobber :(
	mov esi, dword ptr [ebp - 54h]
	lea esi, [esi + 4 * eax]			;traverse the singly-linked list
LJenergyEval4:
	mov eax, dword ptr [esi]
	test eax, eax
	jz LJenergyEval5
	mov esi, eax
	jmp LJenergyEval4
LJenergyEval5:
	; allocate. esi is now pointing to last node.
	invoke GlobalAlloc, 40h, 8
	mov dword ptr [esi], eax			;set next of previously last node
	mov ebx, dword ptr [ebp - 58h]
	mov dword ptr [eax + 4], ebx		;append i to cell list
	mov edi, dword ptr [ebp - 50h]
	mov ecx, dword ptr [ebp - 90h]		;restore ecx!!
	mov dword ptr [edi + 4 * ebx], ecx	;append cell index into cellmap
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	cmp ebx, nPart
	jb LJenergyEval3
	; close loop
	
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 80h], eax
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 84h], eax
	
	; calculate energy
	; big outer loop
	mov dword ptr [ebp - 58h], 0
LJenergyEval6:
	mov ebx, dword ptr [LJn]
	mov esi, ebx
	imul esi, ebx
	mov ecx, dword ptr [ebp - 58h]
	mov edi, dword ptr [ebp - 50h]
	mov eax, dword ptr [edi + 4 * ecx]
	mov ecx, eax
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 5ch], edx
	mov eax, ecx						;restore
	xor edx, edx
	idiv ebx
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 60h], edx
	mov eax, ecx
	xor edx, edx
	idiv esi
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 64h], edx
	
	; loop over x offsets
	mov dword ptr [ebp - 68h], 0ffffffffh
LJenergyEval7:

	; loop over y offsets
	mov dword ptr [ebp - 6ch], 0ffffffffh
LJenergyEval8:

	; loop over z offsets
	mov dword ptr [ebp - 70h], 0ffffffffh
LJenergyEval9:
	mov ecx, 3
	lea edi, [ebp - 7ch]
	lea esi, [ebp - 64h]
	rep movsd
	mov eax, dword ptr [ebp - 68h]
	add dword ptr [ebp - 74h], eax
	mov eax, dword ptr [ebp - 6ch]
	add dword ptr [ebp - 78h], eax
	mov eax, dword ptr [ebp - 70h]
	add dword ptr [ebp - 7ch], eax
	
	; loop over dimensions, form correction vector
	mov ecx, 8							;clear out the correction vector!
	xor eax, eax
	mov edi, dword ptr [ebp - 80h]
	rep stosd
	mov ecx, 2
	xor edx, edx
	movsd xmm0, qword ptr [LJLint]
	movsd xmm1, qword ptr [NUNITY]
	mulsd xmm1, xmm0					;xmm1 = -Lint
LJenergyEval10:
	mov ebx, dword ptr [LJn]
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, 0
	jge LJenergyEval11
	; make PBC correction
	add dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm0
	
LJenergyEval11:
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, ebx
	jl LJenergyEval12
	;make PBC correction
	sub dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm1
	
LJenergyEval12:
	inc edx
	dec ecx
	cmp ecx, 0
	jge LJenergyEval10
	
	; loop over neighbor cell list
	mov ebx, dword ptr [ebp - 7ch]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 78h]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 74h]
	mov esi, [ebp - 54h]
	lea edi, [esi + 4 * ebx]			;traverse the singly-linked list
	jmp LJenergyEval14
LJenergyEval13:
	mov edi, eax
	mov ecx, [edi + 4]					;ecx -> particle j
	mov edx, [ebp - 58h]				;edx index of* particle i
	cmp ecx, edx
	jz LJenergyEval14					;continue if same particle
	mov eax, dword ptr [ebp - 84h]
	mov esi, ecx						;go to j
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu [eax], xmm0
	movdqu xmm0, [esi + 10h]
	movdqu [eax + 10h], xmm0
	mov esi, edx						;go to i
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	mov esi, dword ptr [ebp - 80h]		;go to corr
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	lea eax, [ebp - 8ch]
	push eax
	lea eax, [LJrc]
	push eax
	push dword ptr [ebp - 84h]
	call LJuc
	; add energy contribution to current energy
	movsd xmm0, qword ptr [ebp - 8ch]
	mov eax, dword ptr [U]
	addsd xmm0, qword ptr [eax]
	movsd qword ptr [eax], xmm0
	
LJenergyEval14:
	mov eax, dword ptr [edi]
	test eax, eax
	jnz LJenergyEval13					;fallthrough if all done
	
LJenergyEval15:
	inc dword ptr [ebp - 70h]
	cmp dword ptr [ebp - 70h], 1
	jle LJenergyEval9
	; close loop
	inc dword ptr [ebp - 6ch]
	cmp dword ptr [ebp - 6ch], 1
	jle LJenergyEval8
	; close loop
	inc dword ptr [ebp - 68h]
	cmp dword ptr [ebp - 68h], 1
	jle LJenergyEval7
	; close loop
	
	mov eax, dword ptr [ebp - 58h]
	inc eax
	mov dword ptr [ebp - 58h], eax
	cmp eax, nPart
	jb LJenergyEval6
	; close loop
	
	; clean up and exit
	invoke GlobalFree, dword ptr [ebp - 50h]
	invoke GlobalFree, dword ptr [ebp - 80h]
	invoke GlobalFree, dword ptr [ebp - 84h]
	
	; need to free all of the elements of the linked list
	mov dword ptr [ebp - 58h], 0
LJenergyEval16:
	mov ebx, dword ptr [ebp - 58h]
	mov esi, dword ptr [ebp - 54h]
	lea edi, [esi + 4 * ebx]
	mov esi, dword ptr [edi]
	jmp LJenergyEval18
LJenergyEval17:
	mov edi, esi
	mov esi, dword ptr [edi]
	invoke GlobalFree, edi
LJenergyEval18:
	test esi, esi
	jnz LJenergyEval17					;fallthrough if all done
	
LJenergyEval19:
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	mov eax, dword ptr [LJn]
	imul eax, eax
	imul eax, dword ptr [LJn]
	cmp ebx, eax
	jb LJenergyEval16
	
	; now, free the cell list itself
	invoke GlobalFree, dword ptr [ebp - 54h]
	
	; divide by 2 to correct for over-counting
	mov eax, dword ptr [U]
	movsd xmm0, qword ptr [eax]
	mulsd xmm0, qword ptr [HALF]
	movsd qword ptr [eax], xmm0
	
	; apply long-range corrections
	movsd xmm0, qword ptr [LJrc]
	lea eax, [ebp - 0a8h]
	push eax
	lea eax, [ebp - 0a0h]
	movsd xmm1, qword ptr [NTHREE]
	movsd qword ptr [eax], xmm1
	push eax
	lea eax, [ebp - 98h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm0, qword ptr [ebp - 0a8h]	;xmm0 = (rc / sigma)^(-3)
	movsd xmm1, xmm0
	mulsd xmm1, xmm1
	mulsd xmm1, xmm0					;xmm1 = (rc / sigma)^(-9)
	mov eax, 3
	cvtsi2sd xmm2, eax
	divsd xmm0, xmm2					;xmm0 = (1 / 3) * (rc / sigma)^(-3)
	mov eax, 9
	cvtsi2sd xmm2, eax
	divsd xmm1, xmm2					;xmm1 = (1 / 9) * (rc / sigma)^(-9)
	subsd xmm1, xmm0					;xmm1 = (1 / 9) * (rc / sigma)^(-9) - (1 / 3) * (rc / sigma)^(-3)
	movsd xmm0, [LJLint]
	lea eax, [ebp - 0a8h]
	push eax
	lea eax, [ebp - 0a0h]				;should still be -3
	push eax
	lea eax, [ebp - 98h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	movsd xmm0, qword ptr [ebp - 0a8h]	;xmm0 = (L / sigma)^(-3)
	mulsd xmm0, xmm1					;xmm0 = (L / sigma)^(-3) * {(1 / 9) * (rc / sigma)^(-9) - (1 / 3) * (rc / sigma)^(-3)}
	mov eax, dword ptr [nPart]
	imul eax, eax
	imul eax, 8
	cvtsi2sd xmm1, eax
	movsd xmm2, qword ptr [PI]
	mulsd xmm1, xmm2					;xmm1 = 8 * pi * N^2
	mulsd xmm0, xmm1					;xmm0 = Ec / epsilon
	; add this correction to the energy
	mov eax, dword ptr [U]
	addsd xmm0, qword ptr [eax]
	movsd qword ptr [eax], xmm0
	
	; restore and return
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	mov ebx, dword ptr [ebp - 34h]
	mov ecx, dword ptr [ebp - 38h]
	mov edx, dword ptr [ebp - 3ch]
	mov esi, dword ptr [ebp - 40h]
	mov edi, dword ptr [ebp - 44h]
	add esp, 0b0h
	ret
LJenergyEval endp



LJenergyDiff proc nPart:DWORD, X_:DWORD, L:DWORD, i:DWORD, deltaU:DWORD
	sub esp, 0b0h						;memory corruption much?
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	mov dword ptr [ebp - 34h], ebx
	mov dword ptr [ebp - 38h], ecx
	mov dword ptr [ebp - 3ch], edx
	mov dword ptr [ebp - 40h], esi
	mov dword ptr [ebp - 44h], edi
	
	; start
	mov eax, [LJisset]
	test eax, eax
	jnz LJenergyDiff2					;params already initialized, go evaluate the forces
	
	; initialize
	push dword ptr [L]
	call LJinit
	
LJenergyDiff2:
	mov eax, nPart
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 50h], eax		;cellmap
	; zero out the energy
	mov edi, dword ptr [deltaU]
	xorpd xmm0, xmm0
	movsd qword ptr [edi], xmm0
	mov eax, dword ptr [LJn]
	mov ebx, eax
	imul eax, ebx
	imul eax, ebx
	shl eax, 2
	invoke GlobalAlloc, 40h, eax
	mov dword ptr [ebp - 54h], eax		;cells
	
	; sort particles into cells
	mov dword ptr [ebp - 58h], 0
LJenergyDiff3:
	; extract particle coordinates
	mov esi, dword ptr [ebp - 58h]
	shl esi, 5
	add esi, X_
	movsd xmm0, qword ptr [esi]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 5ch], eax		;nx
	movsd xmm0, qword ptr [esi + 8]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 60h], eax		;ny
	movsd xmm0, qword ptr [esi + 10h]
	divsd xmm0, qword ptr [LJdn]
	cvttsd2si eax, xmm0
	mov dword ptr [ebp - 64h], eax		;nz
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 60h]
	imul eax, dword ptr [LJn]
	add eax, dword ptr [ebp - 5ch]
	mov dword ptr [ebp - 90h], eax		;ecx clobber :(
	mov esi, dword ptr [ebp - 54h]
	lea esi, [esi + 4 * eax]			;traverse the singly-linked list
LJenergyDiff4:
	mov eax, dword ptr [esi]
	test eax, eax
	jz LJenergyDiff5
	mov esi, eax
	jmp LJenergyDiff4
LJenergyDiff5:
	; allocate. esi is now pointing to last node.
	invoke GlobalAlloc, 40h, 8
	mov dword ptr [esi], eax			;set next of previously last node
	mov ebx, dword ptr [ebp - 58h]
	mov dword ptr [eax + 4], ebx		;append i to cell list
	mov edi, dword ptr [ebp - 50h]
	mov ecx, dword ptr [ebp - 90h]		;restore ecx!!
	mov dword ptr [edi + 4 * ebx], ecx	;append cell index into cellmap
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	cmp ebx, nPart
	jb LJenergyDiff3
	; close loop
	
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 80h], eax
	invoke GlobalAlloc, 40h, 32
	mov dword ptr [ebp - 84h], eax
	
	; calculate interactions between particle i and others
LJenergyDiff6:
	mov ebx, dword ptr [LJn]
	mov esi, ebx
	imul esi, ebx
	mov ecx, dword ptr [i]
	mov edi, dword ptr [ebp - 50h]
	mov eax, dword ptr [edi + 4 * ecx]
	mov ecx, eax
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 5ch], edx
	mov eax, ecx						;restore
	xor edx, edx
	idiv ebx
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 60h], edx
	mov eax, ecx
	xor edx, edx
	idiv esi
	xor edx, edx
	idiv ebx
	mov dword ptr [ebp - 64h], edx
	
	; loop over x offsets
	mov dword ptr [ebp - 68h], 0ffffffffh
LJenergyDiff7:

	; loop over y offsets
	mov dword ptr [ebp - 6ch], 0ffffffffh
LJenergyDiff8:

	; loop over z offsets
	mov dword ptr [ebp - 70h], 0ffffffffh
LJenergyDiff9:
	mov ecx, 3
	lea edi, [ebp - 7ch]
	lea esi, [ebp - 64h]
	rep movsd
	mov eax, dword ptr [ebp - 68h]
	add dword ptr [ebp - 74h], eax
	mov eax, dword ptr [ebp - 6ch]
	add dword ptr [ebp - 78h], eax
	mov eax, dword ptr [ebp - 70h]
	add dword ptr [ebp - 7ch], eax
	
	; loop over dimensions, form correction vector
	mov ecx, 8							;clear out the correction vector!
	xor eax, eax
	mov edi, dword ptr [ebp - 80h]
	rep stosd
	mov ecx, 2
	xor edx, edx
	movsd xmm0, qword ptr [LJLint]
	movsd xmm1, qword ptr [NUNITY]
	mulsd xmm1, xmm0					;xmm1 = -Lint
LJenergyDiff10:
	mov ebx, dword ptr [LJn]
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, 0
	jge LJenergyDiff11
	; make PBC correction
	add dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm0
	
LJenergyDiff11:
	mov eax, dword ptr [ebp - 7ch + 4 * ecx]
	cmp eax, ebx
	jl LJenergyDiff12
	;make PBC correction
	sub dword ptr [ebp - 7ch + 4 * ecx], ebx
	mov eax, dword ptr [ebp - 80h]
	movsd qword ptr [eax + 8 * edx], xmm1
	
LJenergyDiff12:
	inc edx
	dec ecx
	cmp ecx, 0
	jge LJenergyDiff10
	
	; loop over neighbor cell list
	mov ebx, dword ptr [ebp - 7ch]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 78h]
	imul ebx, dword ptr [LJn]
	add ebx, dword ptr [ebp - 74h]
	mov esi, [ebp - 54h]
	lea edi, [esi + 4 * ebx]			;traverse the singly-linked list
	jmp LJenergyDiff14
LJenergyDiff13:
	mov edi, eax
	mov ecx, [edi + 4]					;ecx -> particle j
	mov edx, dword ptr [i]				;edx index of* particle i
	cmp ecx, edx
	jz LJenergyDiff14					;continue if same particle
	mov eax, dword ptr [ebp - 84h]
	mov esi, ecx						;go to j
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu [eax], xmm0
	movdqu xmm0, [esi + 10h]
	movdqu [eax + 10h], xmm0
	mov esi, edx						;go to i
	shl esi, 5
	add esi, X_
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	mov esi, dword ptr [ebp - 80h]		;go to corr
	movdqu xmm0, [esi]
	movdqu xmm1, [eax]
	subpd xmm1, xmm0
	movdqu [eax], xmm1
	movdqu xmm0, [esi + 10h]
	movdqu xmm1, [eax + 10h]
	subpd xmm1, xmm0
	movdqu [eax + 10h], xmm1
	lea eax, [ebp - 8ch]
	push eax
	lea eax, [LJrc]
	push eax
	push dword ptr [ebp - 84h]
	call LJuc
	; add energy contribution to current energy
	movsd xmm0, qword ptr [ebp - 8ch]
	mov eax, dword ptr [deltaU]
	addsd xmm0, qword ptr [eax]
	movsd qword ptr [eax], xmm0
	
LJenergyDiff14:
	mov eax, dword ptr [edi]
	test eax, eax
	jnz LJenergyDiff13					;fallthrough if all done
	
LJenergyDiff15:
	inc dword ptr [ebp - 70h]
	cmp dword ptr [ebp - 70h], 1
	jle LJenergyDiff9
	; close loop
	inc dword ptr [ebp - 6ch]
	cmp dword ptr [ebp - 6ch], 1
	jle LJenergyDiff8
	; close loop
	inc dword ptr [ebp - 68h]
	cmp dword ptr [ebp - 68h], 1
	jle LJenergyDiff7
	; close loop
	
	; clean up and exit
	invoke GlobalFree, dword ptr [ebp - 50h]
	invoke GlobalFree, dword ptr [ebp - 80h]
	invoke GlobalFree, dword ptr [ebp - 84h]
	
	; need to free all of the elements of the linked list
	mov dword ptr [ebp - 58h], 0
LJenergyDiff16:
	mov ebx, dword ptr [ebp - 58h]
	mov esi, dword ptr [ebp - 54h]
	lea edi, [esi + 4 * ebx]
	mov esi, dword ptr [edi]
	jmp LJenergyDiff18
LJenergyDiff17:
	mov edi, esi
	mov esi, dword ptr [edi]
	invoke GlobalFree, edi
LJenergyDiff18:
	test esi, esi
	jnz LJenergyDiff17					;fallthrough if all done
	
LJenergyDiff19:
	inc ebx
	mov dword ptr [ebp - 58h], ebx
	mov eax, dword ptr [LJn]
	imul eax, eax
	imul eax, dword ptr [LJn]
	cmp ebx, eax
	jb LJenergyDiff16
	
	; now, free the cell list itself
	invoke GlobalFree, dword ptr [ebp - 54h]
	
	; restore and return
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	mov ebx, dword ptr [ebp - 34h]
	mov ecx, dword ptr [ebp - 38h]
	mov edx, dword ptr [ebp - 3ch]
	mov esi, dword ptr [ebp - 40h]
	mov edi, dword ptr [ebp - 44h]
	add esp, 0b0h
	ret
LJenergyDiff endp



init3DGrid proc nPart:DWORD, dens:DWORD, L:DWORD, grid:DWORD
	sub esp, 90h
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	movdqu [ebp - 40h], xmm3
	mov dword ptr [ebp - 44h], ebx
	mov dword ptr [ebp - 48h], ecx
	mov dword ptr [ebp - 4ch], edx
	mov dword ptr [ebp - 50h], esi
	mov dword ptr [ebp - 54h], edi
	
	; get the box - commenting out because caller should ideally provide this memory
;	mov eax, nPart
;	shl eax, 5							;3 dimensions (go ahead and allocate 4 dims, 8 bytes per dim)
;	invoke GlobalAlloc, 40h, eax
;	mov edi, grid
;	mov dword ptr [edi], eax
	
	; calculate box side length
	mov eax, nPart
	cvtsi2sd xmm0, eax
	mov eax, dens
	movsd xmm1, qword ptr [eax]
	divsd xmm0, xmm1
	push dword ptr [L]
	movsd xmm1, qword ptr [THIRD]
	lea eax, [ebp - 80h]
	movsd qword ptr [eax], xmm1
	push eax
	lea eax, [ebp - 70h]
	movsd qword ptr [eax], xmm0
	push eax
	call pow
	
	; calculate particles per side
	mov ebx, 1
init3DGrid1:
	inc ebx
	mov eax, ebx
	imul eax, eax
	imul eax, ebx
	cmp eax, nPart
	jb init3DGrid1
	mov esi, ebx
	imul esi, ebx						;esi = nside^2
	
	; calculate spacing
	cvtsi2sd xmm2, ebx					;xmm2 = nside
	mov eax, L
	movsd xmm3, qword ptr [eax]
	divsd xmm3, xmm2					;xmm3 = L / nside
	mov dword ptr [ebp - 84h], 0
	
	;loop to populate particles
	mov edi, grid
;	mov edi, dword ptr [edi]
	movsd xmm0, qword ptr [HALF]
init3DGrid2:
	mov ecx, dword ptr [ebp - 84h]		;ecx = i
	
	; first dimension
	mov eax, ecx				
	xor edx, edx
	idiv ebx
	cvtsi2sd xmm2, edx
	addsd xmm2, xmm0
	mulsd xmm2, xmm3
	mov eax, ecx
	shl eax, 5
	movsd qword ptr [edi + eax], xmm2
	
	; second dimension
	mov eax, ecx
	xor edx, edx
	idiv ebx
	xor edx, edx
	idiv ebx
	cvtsi2sd xmm2, edx
	addsd xmm2, xmm0
	mulsd xmm2, xmm3
	mov eax, ecx
	shl eax, 5
	movsd qword ptr [edi + eax + 8], xmm2
	
	; third dimension
	mov eax, ecx
	xor edx, edx
	idiv esi
	xor edx, edx
	idiv ebx
	cvtsi2sd xmm2, edx
	addsd xmm2, xmm0
	mulsd xmm2, xmm3
	mov eax, ecx
	shl eax, 5
	movsd qword ptr [edi + eax + 10h], xmm2
	
	; loop
	inc dword ptr [ebp - 84h]
	mov eax, nPart
	cmp dword ptr [ebp - 84h], eax
	jb init3DGrid2
	
	; restore and return
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	movdqu xmm3, [ebp - 40h]
	mov ebx, dword ptr [ebp - 44h]
	mov ecx, dword ptr [ebp - 48h]
	mov edx, dword ptr [ebp - 4ch]
	mov esi, dword ptr [ebp - 50h]
	mov edi, dword ptr [ebp - 54h]
	add esp, 90h
	ret
init3DGrid endp



pow proc base:DWORD, power:DWORD, result:DWORD
	mov eax, power
	fld qword ptr [eax]					;st0 = power
	mov eax, base
	fld qword ptr [eax]					;st0 = base | st1 = power
	fyl2x								;st0 = power * lg(base)
	fld1								;st0 = 1 | st1 = power * lg(base)
	fld st(1)							;st0 = power * lg(base) | st1 = 1 | st2 = power * lg(base)
	fprem								;st0 = rem | st1 = 1 | st2 = power * lg(base)
	f2xm1								;st0 = 2^rem - 1 | st1 = 1 | st2 = power * lg(base)
	faddp								;st0 = 2^rem | st1 = power * lg(base)
	fscale								;st0 = 2^(rem + round(power * lg(base))) | st1 = power * lg(base)
	fstp st(1)							;st0 = 2^(rem + round(power * lg(base)))
	mov eax, result
	fstp qword ptr [eax]				;store the result
	ret
pow endp



; fast inverse square root (does not use FPU)
; based on the famous "Quake" algorithm
; don't use this - it's not significantly faster than pow
; and is not as accurate
fastinvsqrt proc number:DWORD, result:DWORD
	sub esp, 40h
	movdqu [ebp - 10h], xmm0
	movdqu [ebp - 20h], xmm1
	movdqu [ebp - 30h], xmm2
	movdqu [ebp - 40h], xmm3
	
	; main bit-fiddling algorithm
	mov eax, number
	movsd xmm0, qword ptr [eax]
	movsd xmm2, xmm0
	movsd xmm1, qword ptr [HALF]
	mulsd xmm2, xmm1					;xmm2 == 0.5 * number
	psrlq xmm0, 1
	movsd xmm1, qword ptr [MAGIC]		;wtf?
	psubq xmm1, xmm0					;xmm1 == y
	
	; perform three iterations of N-R
	movsd xmm0, xmm1
	mulsd xmm0, xmm0
	mulsd xmm0, xmm2
	movsd xmm3, qword ptr [THREEHALF]
	subsd xmm3, xmm0
	mulsd xmm1, xmm3
	movsd xmm0, xmm1
	mulsd xmm0, xmm0
	mulsd xmm0, xmm2
	movsd xmm3, qword ptr [THREEHALF]
	subsd xmm3, xmm0
	mulsd xmm1, xmm3
	movsd xmm0, xmm1
	mulsd xmm0, xmm0
	mulsd xmm0, xmm2
	movsd xmm3, qword ptr [THREEHALF]
	subsd xmm3, xmm0
	mulsd xmm1, xmm3
	
	; store the result
	mov eax, result
	movsd qword ptr [eax], xmm1
	movdqu xmm0, [ebp - 10h]
	movdqu xmm1, [ebp - 20h]
	movdqu xmm2, [ebp - 30h]
	movdqu xmm3, [ebp - 40h]
	add esp, 40h
	ret
fastinvsqrt endp



end LibMain								;end of the dll