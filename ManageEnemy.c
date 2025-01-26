

//					  Nstep, vrx,vry,vrz,fr,
                     
i8 EnemyPath0[] = {		127,	0,	0,	1, 1,
						 10,   -1,	0,	1, 0,
						 31,   -1,	0,	1,-1,
					  	 32,   -2,  0,  1,-2,
						-1};
						

i8 EnemyPath1[] = {		127,	0,	0,	1,-1,
						 10,    1,	0,	1, 0,
						 31,	1,	0,	1, 1,
					  	 32,    2,  0,  1, 2,
						-1};
						
i8 EnemyPath2[] = {		127,	0,	0,	-1, 1,
						 10,   -1,	0,	-1, 0,
						 31,   -1,	0,	-1,-1,
					  	 32,   -2,  0, 	-1,-2,
						-1};

i8 EnemyPath3[] = {		127,	0,	0,	-1,-1,
						 10,    1,	0,	-1, 0,
						 31,	1,	0,	-1, 1,
					  	 32,    2,  0,  -1, 2,
						-1};
						
i8 EnemyPathExp[] = {	4,	0,0,0,0,
						4,	0,0,0,1,
						4,	0,0,0,2,
						4,	0,0,0,3,
						-1};
						
u16 EnGraphic[] = {0,0,0,0,EnStart,EnStart+1*30*16,EnStart+2*30*16,EnStart+3*30*16,EnStart+4*30*16,ExpStart};

void AnimateExplosion(u8 i,Object *pMyObj)
{
	if (pMyObj->NumSteps==0) 	// 
	{
		pMyObj->PathNode += 5;
		pMyObj->NumSteps  = *(pMyObj->PathNode+0);		
		
		if (pMyObj->NumSteps<0) // -1 == End of the list
		{
			pMyObj->Type     = EnIdle;	
			pMyObj->Status 	 = Active;
			pMyObj->x = -256;			
			pMyObj->rz = 0;			
			pMyObj->NumSteps = 64 + (Math_GetRandom8() & 63);
			return;
		}
		else					// Next node
		{
			pMyObj->FrameOff	= *(pMyObj->PathNode+4);
		}
	}
	
	if (pMyObj->NumSteps>0) 
	{
		pMyObj->NumSteps--;

		static	i16 x0,y0,z0;
		static	i16 x1;
		static	i16 x2,y2,z2;
		
		x0 = pMyObj->rx/2;
		y0 = pMyObj->ry/2;
		z0 = pMyObj->rz/2;

		// pitch (around Y)
		x1 =  (cp*x0+sp*z0)/256;	// 8.8 * 16.0 + 8.8 * 15.0
		z2 =  (cp*z0-sp*x0)/128;	// 8.8 * 15.0 + 8.8 * 16.0
					
		// yaw (around Z)
		x2 = (cy*x1-sy*y0)/128 	;	//8.8 * 16.0
		y2 = (sy*x1+cy*y0)/128 	;	//8.8 * 16.0

					
		if (z2>0) {
			pMyObj->x = xc + x2*d/z2;
			pMyObj->y = yc + y2*d/z2;
			
			u8 Scale = (z2<d) ? (0):((z2-d)/8);		// 128/8 = 16
			if (Scale>15) 	Scale = 15;

			i8 Frame = pMyObj->FrameOff ;
						
			SetObjFrame(i,Scale+Frame*16+ExpStart);
		} 
		else {
			pMyObj->x = -256;
		}
		
	} 
}

						
void MoveEnemy(u8 i,Object *pMyObj)
{
	if (pMyObj->NumSteps==0) 	// 
	{
		pMyObj->PathNode += 5;
		pMyObj->NumSteps  = *(pMyObj->PathNode+0);		
		
		if (pMyObj->NumSteps<0) // -1 == End of the list
		{
			pMyObj->Type     = EnIdle;	
			pMyObj->x = -256;			
			pMyObj->rz = 0;			
			pMyObj->NumSteps = 64 + (Math_GetRandom8() & 63);
			return;
		}
		else					// Next node
		{
			pMyObj->vrx		    = *(pMyObj->PathNode+1);
			pMyObj->vry		    = *(pMyObj->PathNode+2);
			pMyObj->vrz		    = *(pMyObj->PathNode+3);
			pMyObj->FrameOff	= *(pMyObj->PathNode+4);
		}
	}
	
	if (pMyObj->NumSteps>0) 
	{
		if (Keyboard_IsKeyPressed(KEY_SPACE))
		{
			pMyObj->Status = Explode;
			pMyObj->PathNode = &EnemyPathExp[-5];			
			pMyObj->NumSteps = 0;
			return;
		}

		
		pMyObj->rx += pMyObj->vrx;
		pMyObj->ry += pMyObj->vry;
		pMyObj->rz += pMyObj->vrz;
		pMyObj->NumSteps--;

		static	i16 x0,y0,z0;
		static	i16 x1;
		static	i16 x2,y2,z2;
		
		x0 = pMyObj->rx/2;
		y0 = pMyObj->ry/2;
		z0 = pMyObj->rz/2;

		// pitch (around Y)
		x1 =  (cp*x0+sp*z0)/256;	// 8.8 * 16.0 + 8.8 * 15.0
		z2 =  (cp*z0-sp*x0)/128;	// 8.8 * 15.0 + 8.8 * 16.0
					
		// yaw (around Z)
		x2 = (cy*x1-sy*y0)/128 	;	//8.8 * 16.0
		y2 = (sy*x1+cy*y0)/128 	;	//8.8 * 16.0

					
		if (z2>0) {
			pMyObj->x = xc + x2*d/z2;
			pMyObj->y = yc + y2*d/z2;
			
			u8 Scale = (z2<d) ? (0):((z2-d)/8);		// 128/8 = 16
			if (Scale>15) 	Scale = 15;

			i8 Frame = pMyObj->FrameOff + tilt;
			if (Frame>30)	Frame -=30;
			if (Frame<0)	Frame +=30;				
			
			
			SetObjFrame(i,Scale+Frame*16+EnGraphic[pMyObj->Type]);
		} 
		else {
			pMyObj->x = -256;
		}
		
	} 
}

void SpawnEnemy(Object *pMyObj,enum ObjType CurrentEnemy)
{

	u8 t = 32+(Math_GetRandom8() % 26);
	pMyObj->rx = (40 * MyCos[t])/256;
	pMyObj->ry = (40 * MySin[t])/256;
	pMyObj->rz = 1;
	
	if (pMyObj->rx<0)
		pMyObj->PathNode = &EnemyPath0[-5];
	else 
		pMyObj->PathNode = &EnemyPath1[-5];
	
	pMyObj->Type = CurrentEnemy;	
	pMyObj->NumSteps = 1;
	
}

void SpawnEnemyAttac(Object *pMyObj,enum ObjType CurrentEnemy)
{

	u8 t = 32+(Math_GetRandom8() % 26);
	pMyObj->rx = (60 * MyCos[t])/256;
	pMyObj->ry = (60 * MySin[t])/256;
	pMyObj->rz = 192;
	
	if (pMyObj->rx<0)
		pMyObj->PathNode = &EnemyPath2[-5];
	else 
		pMyObj->PathNode = &EnemyPath3[-5];
	
	pMyObj->Type = CurrentEnemy;	
	pMyObj->NumSteps = 1;
	
}
