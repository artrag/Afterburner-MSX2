#include "msxgl.h"
#include "template.h"



void WritePAT(u8 seg,u16 src, u16 dest,u8 vpag)
{
	seg;	// A
	src;   	// DE
	dest;  	// stack word
	vpag;	// stack byte
	
	__asm
		di
		pop iy
		pop bc				// BC = dest
		ld		(0x6000),a

		pop 	af			// CF = vpag
		dec 	sp
		
		ld		a, b
		rla 				//  B1 B0 CF	CF enters in A
		rla					//  B0 CF B7	B7 enters in A from CF
		rla					//  CF B7 B6	B6 enters in A from CF
		and		a,#7
		
		// Setup address register
		out		(P_VDP_ADDR), a
		ld		a, #0x0e + #0x80
		out		(P_VDP_ADDR), a
		
		ld		a, c
		out		(P_VDP_ADDR), a			// RegPort = (dest & 0xFF)
		ld		a, b
		and 	a, #0x3F
		or		a, #F_VDP_WRIT
		out		(P_VDP_ADDR), a			// RegPort = ((dest >> 8) & 0x3F) + F_VDP_WRIT

		ex 		de,hl	// hl = src

		ld		a,#32
		ld		bc,#P_VDP_DATA			// data register 
_myloop:	
		otir							// one line => 8*32 = 256 bytes
		dec a							// 32 lines
		jp nz,_myloop
		
		xor 	a
		ld		(0x6000),a
		ei
		jp (iy)
	__endasm;
}


void WritePNT(u8 pag,u16 src)
{
	pag;	// A
	src;   	// DE
	
	__asm
		di
		ld		(0x6000),a

		// Setup address register 0x1800
		xor 	a
		out		(P_VDP_ADDR), a
		ld	a, #0x0e + #0x80
		out		(P_VDP_ADDR), a

		xor 	a
		out		(P_VDP_ADDR), a			// RegPort = (dest & 0xFF)
		ld		a, #0x18 + #F_VDP_WRIT
		out		(P_VDP_ADDR), a			// RegPort = ((dest >> 8) & 0x3F) + F_VDP_WRIT

		ex 		de,hl

		ld		bc,#P_VDP_DATA			// data register 

		// otir							// 256 lines x 4
		// otir							
		// otir							
		// otir							

		.rept 32*32
		outi
		.endm
		
		
		xor 	a
		ld		(0x6000),a
		ei
	__endasm;
}


unsigned char Palette[] = {
0x43,0xDE,0xFF,0x00,0x32,0x15,0xFF,0x7E,0x4C,0xF0,0xF0,0xF0,0x00,0xB9,0x00,0xB4,
0xF0,0x00,0xB5,0xBA,0xC5,0xFF,0xFF,0xFF,0x00,0x4F,0x86,0xDE,0xC1,0x00,0x00,0x4A,
0xC5,0x60,0x60,0x60,0x54,0x7E,0x61,0x93,0xB0,0x9F,0xC0,0x00,0x00,0xE3,0xDE,0xDE
};

void VqVRAMinit(void)  __banked
{
	VDP_SetColor(0);
    VDP_SetMode(VDP_MODE_SCREEN4);
	VDP_ClearVRAM();
	VDP_SetFrequency(VDP_FREQ_60HZ);
   
	VDP_EnableSprite(TRUE);
    VDP_SetSpriteFlag(VDP_SPRITE_SIZE_16);
	VDP_RegWrite(11,0);
	
   // Setup background
    VDP_RegWrite(2,0x06);		// PNT 0x1800
    VDP_RegWrite(3,0x00);		// CT  0x0000

	for (u8 i=0;i<16;i++)
	{
		u8 g = Palette[i*3+0]*(u16)7/255;
		u8 r = Palette[i*3+1]*(u16)7/255;
		u8 b = Palette[i*3+2]*(u16)7/255;
		VDP_SetPaletteEntry( i, 256*r+16*g+b);
	}


	// colors 
	
    for (u16 t=0;t<8*8;t++)
    {
        VDP_Poke(0xF8,t+0x0000,0);
//        VDP_Poke(0xFA,t+0x0800,0);
//        VDP_Poke(0xF9,t+0x1000,0);
//        VDP_Poke(0xF8,t+0x1800,0);	// Affecting the PNT
    }	

	u32 addr = 0x2000;
	for (u8 i=0;i<15;i++)
	{
		WritePAT(16+i,(u16)0x4000,(u16)addr,(addr)>>16);
		addr += 0x2000;
	}

}

void Draw_Horizon(u8 tilt,u8 frame) __banked
{
	if (tilt<15)
	{
		VDP_RegWrite(4,(0x03 | (1+tilt)*4));		// PT  0x2000,0x4000,0x6000 etc
		WritePNT(16+tilt,0x6000+frame*0x400);		// frame in 0-2
	}
	else
	{
		tilt-=15;
		VDP_RegWrite(4,(0x03 | (1+tilt)*4));		// PT  0x2000,0x4000,0x6000 etc
		WritePNT(16+tilt,0x6C00+frame*0x400);		// frame in 0-2
	}
}

