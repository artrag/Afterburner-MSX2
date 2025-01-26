// ____________________________
// ██▀▀█▀▀██▀▀▀▀▀▀▀█▀▀█        │   ▄▄▄                ▄▄      
// ██  ▀  █▄  ▀██▄ ▀ ▄█ ▄▀▀ █  │  ▀█▄  ▄▀██ ▄█▄█ ██▀▄ ██  ▄███
// █  █ █  ▀▀  ▄█  █  █ ▀▄█ █▄ │  ▄▄█▀ ▀▄██ ██ █ ██▀  ▀█▄ ▀█▄▄
// ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀────────┘                 ▀▀
//  Program template
//─────────────────────────────────────────────────────────────────────────────

//const extern u8 SprtColDef[];
//const extern u8 SprtPatDef[];

// distanza z dallo schermo dell'osservatore
extern const u8 d;
extern const u8 xc;
extern const u8 yc;



#define SptAddr0	(0x0000+32*32)
#define SctAddr0	0x1400
#define SatAddr0	0x1600

#define SptAddr1	(0x0800+32*32)
#define SctAddr1	0x1C00
#define SatAddr1	0x1E00

void SatUpdate(void) __banked;
void SatInit(void) 	 __banked;

#define MaxNumObj 16
#define EnStart (36+4*16)
#define ExpStart (36)

enum ObjType {EnIdle, MyPlayer, MyBullet, MyMissile, EnPlane0, EnPlane1, EnPlane2, EnPlane3, EnPlane4, EnExplode, EnMissile0, EnMissile1};
enum ObjStat {Inactive, Active, Explode};

typedef struct
{
    i16         x;  
    i16         y;  
    i16         z;  
} Vec3D;


typedef struct
{
    i16         x;  
    i16         y;  
} Vec2D;


typedef struct {
	enum ObjStat Status;
	enum ObjType Type;
	i16	x,y;
	u8 NumSprt;
	u8 *dx,*dy;
	u16 *pat,*col;
	i16	rx,ry,rz;
	i16 vrx,vry,vrz;
	i8 NumSteps;
	i8 FrameOff;
	i8*	PathNode;
	u8 seg;	
} Object;

extern Object MyObject[];

extern i16 cy,sy,cp,sp,cr,sr;

extern const unsigned char  FrameOffset[];

void SetObjFrame(u8 ObjNum,u16 FrmNum) __banked;

extern u8	COL0[32];
extern u8	COL1[32];

extern u16	PAT0[32];
extern u16	PAT1[32];

void MyWriteSAT(const u8* src, u16 dest);
void MyWritePAT(u16 src, u16 dest);
void MyWriteCOL(u16 src, u16 dest);

extern u8 Sprt_flip;

void VRAMinit(void);
extern unsigned char palette[];

///////////////////

void VqVRAMinit(void)  __banked;
void Draw_Horizon(u8 tilt,u8 frame) __banked;

extern unsigned char Palette[];
void Move_Player(void) __banked;

void ObjInit(void) __banked;


extern const i16 MyCos[];
extern const i16 MySin[];

// enemy trajectories

extern i8 EnemyPath0[];
extern i8 EnemyPath1[];

void SpawnEnemy(Object *pMyObj,enum ObjType CurrentEnemy);
void AnimateExplosion(u8 i,Object *pMyObj);

void Choose_Enemy(void);