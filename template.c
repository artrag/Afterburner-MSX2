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
#include "bios_hook.h"
#include "msxgl_config.h"
#include "template.h"
#include "system.h"
#include "math.h" 

// Fake mapper init to make openmsx happy
void FakeInit(void) {
__asm
	xor a
	ld (0x6000),a
	inc a
	ld (0x7000),a
__endasm;
}
	
#include "sincos.c"

u8 Sprt_flip = 0;

u8 FrameNum = 0;

void VBlankHook(void)
{
	if (Sprt_flip) {
		VDP_RegWrite(6,(u8) (SptAddr0>>11));
		VDP_RegWrite(5,(u8) ((SatAddr0>>7) | 0b111));
	} else {
		VDP_RegWrite(6,(u8) (SptAddr1>>11));
		VDP_RegWrite(5,(u8) ((SatAddr1>>7) | 0b111));
	}
	FrameNum++;
}

/////////////////////////////////////////////////////
// shared with Move_Player (!!)
i16 PlayerFrame = 4;
i8 	tilt = 15;
i8 	vert = 32;
i8  ObjTilt = 15;
i8  Tonneau  = 0;		// >0 senso orario, <0 senso antiorario

// distanza z dallo schermo dell'osservatore
const u8 d = 64;
const u8 xc = 128;
const u8 yc = 128;
/////////////////////////////////////////////////////
#include "ManageEnemy.c"
/////////////////////////////////////////////////////

static i8 y = 0;	// around z ; yaw 
static i8 p = 0;  	// around y ; pitch
static i8 r = 0;	// around x ; roll

enum ObjType CurrentEnemy;

i16 cy,sy,cp,sp,cr,sr;
	
void main(void)
{
	
	static Object* pMyObj;
	static u8 i;

    if (Bios_GetMSXVersion() == MSXVER_TR)
		Bios_SetCPUMode(CPU_MODE_R800_DRAM);
	
	// Initialise data for dynamic sprite management
	SatInit();
	
	// Initialise enemies
	CurrentEnemy = EnPlane0;
	ObjInit();
	
	VqVRAMinit();

	// Set TP bit
	VDP_RegWriteBakMask(8,0xDF,0x20);
	
	Bios_SetHookCallback(H_TIMI, VBlankHook);
	
	u8 timer = 0;
	u8 FpsCount = 1;
	
	u8 EnWaveCount = 0;


	
	while(1)	{
	
		// ALLOW FULL TROTTLE
		if (!Keyboard_IsKeyPressed(KEY_ESC))
		{
			Halt();    		         // Wait V-Blank
			VDP_RegWrite(23,vert);
			Draw_Horizon(tilt,((timer) % (3*2))/2);
			SatUpdate();
			Sprt_flip ^= 1;	
		}
		else
		{
			VDP_RegWrite(23,vert);
			Draw_Horizon(tilt,((timer) % (3*2))/2);
			Sprt_flip ^= 1;	
		}
		
		// SHOW FPS
		if (FrameNum>59) 
		{
			FrameNum = 0;
			FpsCount = timer;
			timer = 0;
		}
		if (tilt==15) 
		{
			VDP_Poke(Math_Div10(FpsCount)+240,0x1900,0);
			VDP_Poke(Math_Mod10(FpsCount)+240,0x1901,0);
		}
		
		Choose_Enemy();
		
		Move_Player();
	
		y = 2*tilt-30;		// around z ; yaw 
		if (y<0) y+=60;
		
		cy = MyCos[y];		// around z ; yaw 
		sy = MySin[y];
		
		p = sy/32;
		if (p<0)  p+=60;
		if (p>59) p-=60;
		
		cp = MyCos[p];		// around y ; pitch
		sp = MySin[p];
	
	
		for (i=1,pMyObj = &MyObject[1];i<MaxNumObj;i++,pMyObj++)
		{
			static	i16 x0,y0,z0;
			static	i16 x1,y1,z1;
			static	i16 x2,y2,z2;

			switch (pMyObj->Status) 
			{
				case Inactive:
				default: break;

				case Explode: {
					AnimateExplosion(i,pMyObj);		// manage explosion
				}
				break;

				case Active:
				switch (pMyObj->Type) 
				{
					default: {
						break;
					}
					case  EnPlane0: 
					case  EnPlane1: 
					case  EnPlane2: 
					case  EnPlane3: 
					case  EnPlane4: 
					{		
						MoveEnemy(i,pMyObj);
					}
					break;					
					case EnIdle: {						// manage respawing
						if (pMyObj->NumSteps) {
							pMyObj->NumSteps--;
						}
						else {
							switch (CurrentEnemy) 
							{
								case  EnPlane0:
								case  EnPlane1:
								case  EnPlane2:
									SpawnEnemy(pMyObj,CurrentEnemy);
									break;
								case  EnPlane3:
								case  EnPlane4:
									SpawnEnemyAttac(pMyObj,CurrentEnemy);
									break;
							}
						}
					}
					break;
				}
			}
		}
		timer ++;
	}
}

void Choose_Enemy(void)
{
	if (Keyboard_IsKeyPressed(KEY_0))
	{
		CurrentEnemy = EnPlane0;
	}
	if (Keyboard_IsKeyPressed(KEY_1))
	{
		CurrentEnemy = EnPlane1;
	}
	if (Keyboard_IsKeyPressed(KEY_2))
	{
		CurrentEnemy = EnPlane2;
	}
	if (Keyboard_IsKeyPressed(KEY_3))
	{
		CurrentEnemy = EnPlane3;
	}
	if (Keyboard_IsKeyPressed(KEY_4))
	{
		CurrentEnemy = EnPlane4;
	}
}