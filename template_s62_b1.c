#include "msxgl.h"
#include "template.h"
#include "memory.h"

extern enum ObjType CurrentEnemy;
	
void ObjInit(void) __banked
{
	u8 i;
	for (i=0;i<MaxNumObj;i++) 
	{
		MyObject[i].Status = 0;
		MyObject[i].NumSteps = 0;
	}

	for (i=0;i<5;i++)
	{
		MyObject[i].Status = Active;
		SpawnEnemy(&MyObject[i],CurrentEnemy);
		MyObject[i].NumSteps = Math_GetRandom8() & 63;		
	}

	MyObject[0].rx = 0; 	// player
	MyObject[0].ry = 0;
	MyObject[0].rz = d;
	MyObject[0].Status = Active;
	MyObject[0].Type = MyPlayer;
}

extern i16 PlayerFrame ;
extern i8 	tilt ;
extern i8 	vert ;
extern i8  ObjTilt;
extern i8  Tonneau;		// >0 senso orario, <0 senso antiorario

///////////////////

void Move_Player(void) __banked
{
	if (Tonneau) 
	{	
		tilt += Tonneau;
		if (tilt>29) tilt=0;
		if (tilt<0) tilt=29;			
		
//		if ((tilt==ObjTilt) && (!Keyboard_IsKeyPressed(KEY_RIGHT) || !Keyboard_IsKeyPressed(KEY_LEFT)))
		if (tilt==ObjTilt)
			Tonneau = 0;
	}
	else 
	{
		if (Keyboard_IsKeyPressed(KEY_RIGHT) && (tilt!=21))   
		{
			PlayerFrame = 5; 
			MyObject[0].rx++; 
			if (MyObject[0].rx>48) 	
				MyObject[0].rx = 48;
			ObjTilt = 9;
			if ((tilt==9) && (Keyboard_IsKeyPressed(KEY_LEFT)) && (MyObject[0].rx>24)) 
			{
				Tonneau = -1;
				ObjTilt = 21;					
//				PlayerFrame = 4; 									
			}
		} 
		else if ((Keyboard_IsKeyPressed(KEY_LEFT)) && (tilt!=9))  
		{
			PlayerFrame = 3; 
			MyObject[0].rx--; 
			if (MyObject[0].rx<-48) 	
				MyObject[0].rx = -48;
			ObjTilt = 21;
			if ((tilt==21) && (Keyboard_IsKeyPressed(KEY_RIGHT)) && (MyObject[0].rx<-24)) 
			{
				Tonneau = +1;
				ObjTilt = 9;
//				PlayerFrame = 4; 				
			}
		}
		else {
			ObjTilt=15;
			PlayerFrame=4;

			if (MyObject[0].rx<0) MyObject[0].rx++;
			else if (MyObject[0].rx>0) MyObject[0].rx--;

		}
		
		if (tilt< ObjTilt) {
			tilt++; 
			if (tilt>29) tilt=0;
		}
		else if (tilt>ObjTilt) 
		{
			tilt--;
			if (tilt<0) tilt=29;
		}
			
	}

	
	if (Keyboard_IsKeyPressed(KEY_UP))   {
		PlayerFrame=1; 
		MyObject[0].ry--; 
		if (MyObject[0].ry<-48) 	
			MyObject[0].ry = -48;
		vert--; 
		if (vert< 0) 	
			vert = 0;
	} 
	else
	if (Keyboard_IsKeyPressed(KEY_DOWN)) {
		PlayerFrame=7; 
		MyObject[0].ry++; 
		if (MyObject[0].ry>48) 	
			MyObject[0].ry = 48;
		vert++; 
		if (vert>64) 	
			vert = 64;
	}
	else
	{
		if (vert>32) 	{vert--;PlayerFrame=1;}
		else if (vert<32) 	{vert++;;PlayerFrame=7;}
		
		if (MyObject[0].ry<0) MyObject[0].ry++;
		else if (MyObject[0].ry>0) MyObject[0].ry--;
	}
	
	if (Keyboard_IsKeyPressed(KEY_UP) 	&& (Keyboard_IsKeyPressed(KEY_LEFT)))   PlayerFrame=0; 
	if (Keyboard_IsKeyPressed(KEY_UP) 	&& (Keyboard_IsKeyPressed(KEY_RIGHT)))  PlayerFrame=2; 
	if (Keyboard_IsKeyPressed(KEY_DOWN) && (Keyboard_IsKeyPressed(KEY_LEFT)))   PlayerFrame=6; 
	if (Keyboard_IsKeyPressed(KEY_DOWN) && (Keyboard_IsKeyPressed(KEY_RIGHT)))  PlayerFrame=8; 

	PlayerFrame = Clamp16(PlayerFrame,0,514);

	// player F14

	SetObjFrame(0,PlayerFrame);	
	
		
	MyObject[0].x = MyObject[0].rx + xc;
	MyObject[0].y = MyObject[0].ry + yc;
		
	
}
/*

static u8 SptFlag[256];


struct SptChunkHeader
{
	i8 Size;
	struct SptChunkHeader* Next;
};

void SptTest() __banked
{
	VDP_SetMode(VDP_MODE_SCREEN0);
	VDP_EnableVBlank(TRUE);
	VDP_ClearVRAM();

	Print_SetTextFont(g_Font_MGL_Sample6, 1);
	Print_SetColor(COLOR_WHITE, COLOR_BLACK);
	
	Spt_DynamicInitialize(&SptFlag[0],256);
	
	u16 t0 = (u16) &SptFlag[0];
	u16 t1 = (u16) Spt_DynamicAlloc(1);
	u16 t2 = (u16) Spt_DynamicAlloc(1);
	u16 t3 = (u16) Spt_DynamicAlloc(1);
	u16 t4 = (u16) Spt_DynamicAlloc(8);
	u16 t5 = (u16) Spt_DynamicAlloc(1);
	u16 t6 = (u16) Spt_DynamicAlloc(1);
	u16 t7 = (u16) Spt_DynamicAlloc(1);
	u16 t8 = (u16) Spt_DynamicAlloc(1);

	Print_SetPosition(0, 0);Print_DrawHex16(t1-t0);
	Print_SetPosition(0, 1);Print_DrawHex16(t2-t0);
	Print_SetPosition(0, 2);Print_DrawHex16(t3-t0);
	Print_SetPosition(0, 3);Print_DrawHex16(t4-t0);
	Print_SetPosition(0, 4);Print_DrawHex16(t5-t0);
	Print_SetPosition(0, 5);Print_DrawHex16(t6-t0);
	Print_SetPosition(0, 6);Print_DrawHex16(t7-t0);
	Print_SetPosition(0, 7);Print_DrawHex16(t8-t0);

	Print_SetPosition(16, 0);Print_DrawHex16(sizeof(struct SptChunkHeader));
	
	while(!Keyboard_IsKeyPressed(KEY_ESC))	{Halt();};
}


//=============================================================================
// DYNAMIC Spt ALLOCATOR
//=============================================================================

// Dynamic Spt chunk flag
#define Spt_CHUNK_FREE				0x8000


// Dynamic Spt chunk root
struct SptChunkHeader* g_SptChunkRoot = NULL;

//-----------------------------------------------------------------------------
// Allocates a static Spt block which can then be used to allocate chunks dynimically.
void Spt_DynamicInitialize(void* base, u16 size) __banked
{
	g_SptChunkRoot = (struct SptChunkHeader*)base;
	g_SptChunkRoot->Size = (size - sizeof(struct SptChunkHeader)) | Spt_CHUNK_FREE;
	g_SptChunkRoot->Next = NULL;
}

//-----------------------------------------------------------------------------
// Allocate a Spt chunk from the dynamic Spt buffer
void* Spt_DynamicAlloc(u16 size) __banked
{
//	if(size == 0)
//		return NULL;

	struct SptChunkHeader* chunk = g_SptChunkRoot;
	while(chunk)
	{
		u16 chunkSize = chunk->Size;
		if(chunkSize & Spt_CHUNK_FREE) 			// Free chunk
		{
			chunkSize &= ~Spt_CHUNK_FREE;
			if(chunkSize == size) 				// Re-use chunk
			{
				chunk->Size &= ~Spt_CHUNK_FREE;
				return (void*)((u16)chunk + sizeof(struct SptChunkHeader));
			}
			u16 needSize = size + sizeof(struct SptChunkHeader);
			if(chunkSize > needSize) 			// Create new sub-chunk
			{
				struct SptChunkHeader* newChunk = (struct SptChunkHeader*)(((u16)chunk) + needSize); // New free sub-chunk
				newChunk->Size = (chunkSize - needSize) | Spt_CHUNK_FREE;
				newChunk->Next = chunk->Next;

				chunk->Size = size; 			// Allocated sub-chunk
				chunk->Next = newChunk;

				return (void*)((u16)chunk + sizeof(struct SptChunkHeader));
			}
		}
		chunk = chunk->Next;		// Here the chunk is busy or too small
	}
	return NULL;
}


//-----------------------------------------------------------------------------
// Merge contiguous empty Spt blocks
void Spt_DynamicMerge() __banked
{
	struct SptChunkHeader* chunk = g_SptChunkRoot;
	while(chunk)
	{
		struct SptChunkHeader* nextChunk = chunk->Next;
		if((nextChunk != NULL) && (chunk->Size & Spt_CHUNK_FREE) && (nextChunk->Size & Spt_CHUNK_FREE))
		{
			chunk->Size += nextChunk->Size + sizeof(struct SptChunkHeader);
//			chunk->Next = nextChunk->Next;
			__builtin_memcpy (&(chunk->Next), &(nextChunk->Next), sizeof(chunk->Next));
		}
		chunk = chunk->Next;
	}
}

//-----------------------------------------------------------------------------
// Free a Spt chunk from the dynamic Spt buffer
void Spt_DynamicFree(void* ptr) __banked
{
	struct SptChunkHeader* chunk = (struct SptChunkHeader*)((u16)ptr - sizeof(struct SptChunkHeader));
	chunk->Size |= Spt_CHUNK_FREE;
	Spt_DynamicMerge();
}
*/