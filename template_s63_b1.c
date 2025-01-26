
#include "msxgl.h"
#include "template.h"


u8		COL0[32];
u8		COL1[32];

u16		PAT0[32];
u16		PAT1[32];

Object MyObject[MaxNumObj];


typedef struct {
	u8 y;
	u8 x;
	u8 p;
	u8 c;
} SatEntry;

SatEntry SAT0[32];
SatEntry SAT1[32];

void SatInit(void) __banked
{
	for (u8 i=0;i<32;i++)
	{
		PAT0[i] = PAT1[i] = 0xFFFF;
		COL0[i] = COL1[i] = 255;
		SAT0[i].p = SAT1[i].p = (32+i)*4;
	}
}

void WriteSAT(const SatEntry* src, u16 dest, u8 len)		// write the SAT
{
	src;   // HL
	dest;  // DE
	len;	// Stack

	__asm
		pop iy
		pop bc
		dec sp
		ld		a, e					// Setup address register
		di 
		out		(P_VDP_ADDR), a			// RegPort = (dest & 0xFF)
		ld		a, d
		or		a, #F_VDP_WRIT
		out		(P_VDP_ADDR), a			// RegPort = ((dest >> 8) & 0x3F) + F_VDP_WRIT
		ld 		b,c
		ld		c,#P_VDP_DATA			// data register 

myloop:	
		outi
		outi
		outi
		outi
		jp nz,myloop
		
		ld	a,#216
		out (c),a
		ei
		jp (iy)
	__endasm;
}



void MyWritePAT(u16 src, u16 dest)		// write one entry (32 bytes) in the Sprite Pattern Table
{
	src;   // HL
	dest;  // DE

	__asm
		di
		ld      a,h
		RRCA
		RRCA
		and 	a,#0x3F
		add		a,#44 					// PAGE 44 HARDCODED
		ld		(0x6000),a
		add hl,hl						// x4
		add hl,hl						// x8
		add hl,hl						// x16
		add hl,hl						// x32
		ld		a,h
		and 	a,#0x3F
		or  	a,#0x40
		ld  	h,a
		// Setup address register
		ld		a, e
		out		(P_VDP_ADDR), a			// RegPort = (dest & 0xFF)
		ld		a, d
		or		a, #F_VDP_WRIT
		out		(P_VDP_ADDR), a			// RegPort = ((dest >> 8) & 0x3F) + F_VDP_WRIT

		ld		c,#P_VDP_DATA			// data register 
		.rept 32
		outi
		.endm
		xor 	a
		ld		(0x6000),a
		ei
	__endasm;

}


void MyWriteCOL(u16 src, u16 dest)		// write one entry (16 bytes) in the Sprite Color Table
{
	src;   // HL
	dest;  // DE

	__asm
		di
		ld      a,h
		RRCA
		RRCA
		and 	a,#0x3F
		add		a,#36					// PAGE 36 HARDCODED
		ld		(0x6000),a
		add hl,hl						// x2		
		add hl,hl						// x4		
		add hl,hl						// x8		
		add hl,hl						// x16		
		ld		a,h
		and 	a,#0x3F
		or  	a,#0x40
		ld  	h,a
		// Setup address register
		ld		a, e
		out		(P_VDP_ADDR), a			// RegPort = (dest & 0xFF)
		ld		a, d
		or		a, #F_VDP_WRIT
		out		(P_VDP_ADDR), a			// RegPort = ((dest >> 8) & 0x3F) + F_VDP_WRIT

		ld		c,#P_VDP_DATA			// data register 
		.rept 16
		outi
		.endm
		xor 	a
		ld		(0x6000),a
		ei
	__endasm;

}


void SatUpdate(void) __banked
{

	static Object* MyObj;
	static u8 ii,jj;
	static i16 SatP,SatC;
	static u16 *ppat;
	static u8 *pcol;
	static u8 n;
	static u16 SptAddr;
	static u16 SctAddr;	
	static i8*  pdy;
	static i8*  pdx;
	static u16* ppt;
	static u16* pcl ;
	static i16  tempx,tempy;
	static SatEntry *psat;
	
	n=0;
	if (Sprt_flip)
	{
		SptAddr = SptAddr1;
		SctAddr = SctAddr1;
		ppat = &PAT1[0];
		pcol = &COL1[0];
		psat = &SAT1[0];
		MyObj = &MyObject[0];
	}
	else 
	{
		SptAddr = SptAddr0;
		SctAddr = SctAddr0;
		ppat = &PAT0[0];
		pcol = &COL0[0];
		psat = &SAT0[0];
		MyObj = &MyObject[MaxNumObj-1];
	}
	for (ii=0;ii<MaxNumObj;ii++)
	{
		if (MyObj->Status >= Active)
		{
			pdy = &(MyObj->dy[0]);
			pdx = &(MyObj->dx[0]);
			ppt = &(MyObj->pat[0]);
			pcl = &(MyObj->col[0]);
			
			for (jj=0;jj<MyObj->NumSprt;jj++)
			{
				u8 prevSeg = GET_BANK_SEGMENT(0);   	// Backup previous segment number 
				DisableInterrupt();
				SET_BANK_SEGMENT(0, MyObj->seg); 
				tempy = (i16)MyObj->y + (i16)*pdy++;
				tempx = (i16)MyObj->x + (i16)*pdx++;
				SatP = *ppt++;
				SatC = *pcl++;
				SET_BANK_SEGMENT(0, prevSeg);           // Restore segment 0
				EnableInterrupt();

				if (n>=32) { goto stop;}
				
				if (((tempx & 0xFF00)==0) && ((tempy<239)&&(tempy>0)))
				{
					
					psat->x = (u8) tempx;
					if ((u8) tempy != 216) 
						psat->y = (u8) tempy;
					else 
						psat->y = 217;
					
					if (*ppat != SatP) 
					{
						*ppat = SatP;
						MyWritePAT(SatP,SptAddr);
					}
					
					if (*pcol != SatC) 
					{
						*pcol = SatC;
						MyWriteCOL(SatC,SctAddr);
					}
					SptAddr += 32;
					SctAddr += 16;
					psat++;
					ppat++;
					pcol++;
					n++;
				} 
			}
		}
		if (Sprt_flip)
			MyObj++;
		else 
			MyObj--;
	}
stop:
	if (Sprt_flip)
	{
		WriteSAT(&SAT1[0],SatAddr1,4*n);
	}
	else 
	{
		WriteSAT(&SAT0[0],SatAddr0,4*n);
	}

}


void SetObjFrame(u8 ObjNum,u16 FrmNum) __banked
{
	u8 Nsp;
	u8* base = (u8*) (FrameOffset[3*FrmNum+0]+256*FrameOffset[3*FrmNum+1]+0x4000);
	u8 NSeg  = (u8)FrameOffset[3*FrmNum+2]+32;	// const offset

	u8 prevSeg = GET_BANK_SEGMENT(0);   	// Backup previous segment number in bank #1 (for mapper ROM)
	DisableInterrupt();
	SET_BANK_SEGMENT(0, NSeg); 
	Nsp = *base;
	SET_BANK_SEGMENT(0, prevSeg);           // Restore the previous segment number in bank #1
	EnableInterrupt();
	
	MyObject[ObjNum].NumSprt = Nsp;
	MyObject[ObjNum].dx  = base + sizeof(u8);
	MyObject[ObjNum].dy  = base + (1+Nsp)*sizeof(u8);
	
	MyObject[ObjNum].pat = base + (1+2*Nsp)*sizeof(u8);
	MyObject[ObjNum].col = base + (1+2*Nsp)*sizeof(u8)+Nsp*sizeof(u16);
	MyObject[ObjNum].seg = NSeg;
}



#include "matlab_sprites\Spt_offset_new_sprt_data.h"
