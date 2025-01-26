// ____________________________
// ██▀▀█▀▀██▀▀▀▀▀▀▀█▀▀█        │   ▄▄▄                ▄▄      
// ██  ▀  █▄  ▀██▄ ▀ ▄█ ▄▀▀ █  │  ▀█▄  ▄▀██ ▄█▄█ ██▀▄ ██  ▄███
// █  █ █  ▀▀  ▄█  █  █ ▀▄█ █▄ │  ▄▄█▀ ▀▄██ ██ █ ██▀  ▀█▄ ▀█▄▄
// ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀────────┘                 ▀▀
//  Program template
//─────────────────────────────────────────────────────────────────────────────

//=============================================================================
// INCLUDES
//=============================================================================
#include "msxgl.h"

//=============================================================================
// DEFINES
//=============================================================================


//=============================================================================
// MAIN LOOP
//=============================================================================

i16 ScalProd2(i8 c,i8 x,i8 s,i8 y)
{
	static i16 outc;
	static i16 outx;
	static i16 outs;
	static i16 outy;
	static i16 out;
	outc = c;
	outs = s;
	outx = x;
	outy = y;
	return out;
}
i16 ScalProd(i16 c,i16 x,i16 s,i16 y)
{
	static i16 outc;
	static i16 outx;
	static i16 outs;
	static i16 outy;
	static i16 out;
	outc = c;
	outs = s;
	outx = x;
	outy = y;

	__asm
    ; x0 = (cy*x2)/256 - (sy*y2)/256 
;    ld  de, (_main_x2_60002_666)
;    ld  hl, (_main_cy_10000_652)
    call    __mulint
    bit 7, d
    jr  Z, ps1
    dec de
    inc d
ps1:
    ld  e,d
    rlc d
    sbc a,a
    ld d,a
    push de
 ;   ld  de, (_main_y2_60002_666)
 ;   ld  hl, (_main_sy_10000_652)
    call    __mulint
    bit 7, d
    jr  Z, ps2
    dec de
    inc d
ps2:    
    ld  e,d
    rlc d
    sbc a,a
    ld d,a
    pop hl 
    and a
    sbc  hl,de
;    ld  (_main_x0_60002_666), hl
	__endasm;
	
	return out;
}	
//-----------------------------------------------------------------------------
/// Program entry point
void main()
{


	i16 c,x,s, y;
	
	u8 count = 0;
	while(!Keyboard_IsKeyPressed(KEY_ESC))
	{
		Halt();
		
		c = count+1;
		x = count+c;
		s = count-1;
		y = count-c;
		count = ScalProd(c, x, s, y);
		count = ScalProd2(c, x, s, y);
	}

	Bios_Exit(0);
}


