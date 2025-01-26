// ____________________________
// ██▀▀█▀▀██▀▀▀▀▀▀▀█▀▀█        │   ▄▄▄                ▄▄      
// ██  ▀  █▄  ▀██▄ ▀ ▄█ ▄▀▀ █  │  ▀█▄  ▄▀██ ▄█▄█ ██▀▄ ██  ▄███
// █  █ █  ▀▀  ▄█  █  █ ▀▄█ █▄ │  ▄▄█▀ ▀▄██ ██ █ ██▀  ▀█▄ ▀█▄▄
// ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀────────┘                 ▀▀
//  by Guillaume 'Aoineko' Blanchard under CC BY-SA license
//─────────────────────────────────────────────────────────────────────────────

//*******************************************************************************
// BUILD STEPS
//*******************************************************************************

// DoClean   = false;	//-- Clear all intermediate files and exit (boolean)
// DoCompile = true;	//-- Compile all the project and engine source code (boolean). Generate all REL files
// DoMake    = true;	//-- Link all the project and engine source code (boolean). Merge all REL into one IHX file
// DoPackage = true;	//-- Generate final binary file (boolean). Binarize the IHX file
// DoDeploy  = true;	//-- Gathering of all files necessary for the program to work (boolean). Depends on the type of target
// DoRun     = false;	//-- Start the program automatically at the end of the build (boolean)

//*****************************************************************************
// DIRECTORIES SETTINGS
//*****************************************************************************

//-- Project directory (string)
ProjDir = `${process.cwd()}/`; // This set the directory from where you executed the build script as the project directory

//-- Intermediate files directory (string)
OutDir = `${ProjDir}out/`;

//*****************************************************************************
// TOOLS SETTINGS
//*****************************************************************************

Compiler  = `${ToolsDir}sdcc/bin/sdcc`;				//-- Path to the C compile program (string)
Assembler = `${ToolsDir}sdcc/bin/sdasz80`;			//-- Path to the assembler program (string)
Linker    = `${ToolsDir}sdcc/bin/sdcc`;				//-- Path to the linker program (string)
MakeLib   = `${ToolsDir}sdcc/bin/sdar`;				//-- Path to the program to generate lib file (string)


Hex2Bin   = `${ToolsDir}MSXtk/bin/MSXhex`;			//-- Path to IHX to binary convertor (string)
MSXDOS    = `${ToolsDir}build/DOS/`;				//-- Path to the MSX-DOS files (string)
DskTool   = `${ToolsDir}build/msxtar/msxtar`;		//-- Path to the tool to generate DSK file (string)
Emulator  = 'C:/Program Files/openMSX';										//-- Path to the emulator to launch the project (string)
// Emulator  = `${ToolsDir}openMSX/openmsx`;
// Emulator  = `${ToolsDir}Emulicious/Emulicious`;
// Emulator  = `${ToolsDir}BlueMSX/blueMSX`;
// Emulator  = `${ToolsDir}MEISEI/meisei`;
// Emulator  = `${ToolsDir}fMSX/fMSX`;
// Emulator  = `${ToolsDir}RuMSX/MSX`;
Debugger  = "";										//-- Path to the debugger to test the project (string)
// Debugger  = `${ToolsDir}openMSX/Debugger/openmsx-debugger`;


//*****************************************************************************
// PROJECT SETTINGS
//*****************************************************************************

//-- Project name (string). Will be use for output filename
ProjName = "template";

//-- List of project modules to build (array). If empty, ProjName will be added
ProjModules = [ ProjName ];

//-- Project segments base name (string). ProjName will be used if not defined
// ProjSegments = "";

//-- List of library modules to build (array)
LibModules = ["system","bios", "vdp", "input","math"];

//-- Additional sources to be compiled and linked with the project (array)
// AddSources = [];

//-- Target MSX machine version (string)
//   - 1        MSX1
//   - 2        MSX2
//   - 12       MSX1 and 2 (multi support)
//   - 2K       Korean MSX2 (SC9 support)
//   - 2P       MSX2+
//   - 22P      MSX2 and 2+ (multi support)
//   - 122P     MSX1, 2 and 2+ (multi support)
//   - 0        MSX0
//   - TR       MSX turbo R
//   - 3        MSX3 (reserved)
Machine = "TR";

//-- Target program format (string)
//   - BIN              .bin    BASIC binary program (starting at 8000h)
//   - BIN_USR          .bin    BASIC USR binary driver (starting at C000h)
//   - DOS1             .com    MSX-DOS 1 program (starting at 0100h)
//   - DOS2             .com    MSX-DOS 2 program (starting at 0100h)
//   - DOS2_MAPPER      .com    MSX-DOS 2 launcher to RAM mapper (launcher starting at 0100h, program at 4000h)
//   - DOS0             .com    Direct program boot from disk (starting at 0100h)
//   - ROM_8K           .rom    8 KB ROM in page 1 (4000h ~ 5FFFh)
//   - ROM_8K_P2        .rom    8 KB ROM in page 2 (8000h ~ 9FFFh)
//   - ROM_16K          .rom    16 KB ROM in page 1 (4000h ~ 7FFFh)
//   - ROM_16K_P2       .rom    16 KB ROM in page 2 (8000h ~ BFFFh)
//   - ROM_32K          .rom    32 KB ROM in page 1&2 (4000h ~ BFFFh)
//   - ROM_48K          .rom    48 KB ROM in page 0-2 (0000h ~ BFFFh)
//   - ROM_48K_ISR      .rom    48 KB ROM in page 0-2 (0000h ~ BFFFh) with ISR replacement
//   - ROM_64K          .rom    64 KB ROM in page 0-3 (0000h ~ FFFFh)
//   - ROM_64K_ISR      .rom    64 KB ROM in page 0-3 (0000h ~ FFFFh) with ISR replacement
//   - ROM_ASCII8       .rom    ASCII-8: 8 KB segments for a total of 64 KB to 2 MB
//   - ROM_ASCII16      .rom    ASCII-16: 16 KB segments for a total of 64 KB to 4 MB
//   - ROM_KONAMI       .rom    Konami MegaROM (aka Konami4): 8 KB segments for a total of 64 KB to 2 MB
//   - ROM_KONAMI_SCC   .rom    Konami MegaROM SCC (aka Konami5): 8 KB segments for a total of 64 KB to 2 MB
//   - ROM_NEO8         .rom    NEO-8: 8 KB segments for a total of 1 MB to 32 MB
//   - ROM_NEO16        .rom    NEO-16: 16 KB segments for a total of 1 MB to 64 MB
//Target = "ROM_32K";
Target = "ROM_ASCII16";

//-- ROM mapper total size in KB (number). Must be a multiple of 8 or 16 depending on the mapper type (from 64 to 4096)
// ROMSize = 128;
ROMSize = 4096;


// if you want to put those 4 files in the 5th segment of a 16 KB mapper, you can use "offset" from 0x10000 (4 * 16K) 

RawFiles = [
//    { offset: 0x08000, file:"data/frmpat00.bin" },	//2 
//    { offset: 0x0A000, file:"data/frmpat01.bin" },	//2
//    { offset: 0x0C000, file:"data/frmpat02.bin" },	//3
//    { offset: 0x0E000, file:"data/frmpat10.bin" },	//3
//    { offset: 0x10000, file:"data/frmpat11.bin" }, 	//4
//    { offset: 0x12000, file:"data/frmpat12.bin" },	//4
//    { offset: 0x14000, file:"data/frmpat20.bin" },	//5
//    { offset: 0x16000, file:"data/frmpat21.bin" },	//5
//    { offset: 0x18000, file:"data/frmpat22.bin" }, 	//6
//    { offset: 0x1A000, file:"data/frmpat30.bin" },	//6
//    { offset: 0x1C000, file:"data/frmpat31.bin" },	//7
//    { offset: 0x1E000, file:"data/frmpat32.bin" },	//7
//    { offset: 0x20000, file:"data/frmpat40.bin" }, 	//8
//    { offset: 0x22000, file:"data/frmpat41.bin" },	//8
//    { offset: 0x24000, file:"data/frmpat42.bin" },	//9
	
	{ offset: 0x40000, file:"data/vqtileset00.bin" },	//16
	{ offset: 0x44000, file:"data/vqtileset01.bin" },	//17
	{ offset: 0x48000, file:"data/vqtileset02.bin" },	//18
	{ offset: 0x4C000, file:"data/vqtileset03.bin" },	//19
	
	{ offset: 0x50000, file:"data/vqtileset04.bin" },	//20
	{ offset: 0x54000, file:"data/vqtileset05.bin" },	//21
	{ offset: 0x58000, file:"data/vqtileset06.bin" },	//22
	{ offset: 0x5C000, file:"data/vqtileset07.bin" },	//23
	
	{ offset: 0x60000, file:"data/vqtileset08.bin" },	//24
	{ offset: 0x64000, file:"data/vqtileset09.bin" },	//25
	{ offset: 0x68000, file:"data/vqtileset10.bin" },	//26
	{ offset: 0x6C000, file:"data/vqtileset11.bin" },	//27

	{ offset: 0x70000, file:"data/vqtileset12.bin" },	//28
	{ offset: 0x74000, file:"data/vqtileset13.bin" },	//29
	{ offset: 0x78000, file:"data/vqtileset14.bin" },	//30
//	{ offset: 0x7C000, file:"data/vqtileset15.bin" },	//31

	{ offset: 0x42000, file:"data/vqnmtab00_6p.bin" },	//16
	{ offset: 0x46000, file:"data/vqnmtab01_6p.bin" },	//17
	{ offset: 0x4A000, file:"data/vqnmtab02_6p.bin" },	//18
	{ offset: 0x4E000, file:"data/vqnmtab03_6p.bin" },	//19

	{ offset: 0x52000, file:"data/vqnmtab04_6p.bin" },	//20
	{ offset: 0x56000, file:"data/vqnmtab05_6p.bin" },	//21
	{ offset: 0x5A000, file:"data/vqnmtab06_6p.bin" },	//22
	{ offset: 0x5E000, file:"data/vqnmtab07_6p.bin" },	//23

	{ offset: 0x62000, file:"data/vqnmtab08_6p.bin" },	//24
	{ offset: 0x66000, file:"data/vqnmtab09_6p.bin" },	//25
	{ offset: 0x6A000, file:"data/vqnmtab10_6p.bin" },	//26
	{ offset: 0x6E000, file:"data/vqnmtab11_6p.bin" },	//27

	{ offset: 0x72000, file:"data/vqnmtab12_6p.bin" },	//28
	{ offset: 0x76000, file:"data/vqnmtab13_6p.bin" },	//29
	{ offset: 0x7A000, file:"data/vqnmtab14_6p.bin" },	//30
//	{ offset: 0x7E000, file:"data/vqnmtab15_6p.bin" },	//31

	{ offset: 0x80000, file:"matlab_sprites/Spt_meta_new_sprt_data.bin" },	//32-35
    
	{ offset: 0x90000, file:"matlab_sprites/Col_new_sprt_data.bin" },	//36-43
    { offset: 0xB0000, file:"matlab_sprites/Spt_new_sprt_data.bin" },	//44-47
];

//-- Postpone the ROM startup to let the other ROMs initialize like Disk controller or Network cartridge (boolean)
// ROMDelayBoot = false;

//-- Select RAM in slot 0 and install ISR there (boolean). For MSX with at least 64 KB of RAM
InstallRAMISR = false;

//-- Type of custom ISR to install (string). ISR is install in RAM or ROM depending on Target and InstallRAMISR parameters
//   - VBLANK     V-blank handler
//   - VHBLANK    V-blank and h-blank handler (V9938 or V9958)
//   - V9990      v-blank, h-blank and command end handler (V9990)
//CustomISR = "VBLANK";

//-- Use automatic banked call and trampoline functions (boolean). For mapped ROM
BankedCall = true;

//-- Overwrite RAM starting address (number). For example. 0xE0000 for 8K RAM machine
// ForceRamAddr = 0;

// --List of data files to copy to disk (array)
// DiskFiles = [];

//-- BASIC USR driver default address (number)
// USRAddr = 0xC000;

//-- Parse MSX-DOS command-line arguments
// DOSParseArg = false;

//*******************************************************************************
// SIGNATURE SETTINGS
//*******************************************************************************

//-- Add application signature to binary data (boolean)
AppSignature = true;

//-- Application company (*). Can be 2 character string or 16-bits integer (0~65535)
AppCompany = "GL";

//-- Application ID. Can be 2 character string or 16-bits integer (0~65535)
AppID = "EX";

//-- Application extra data (array). Comma-separated bytes starting with data size
// AppExtra = [];

//*******************************************************************************
// MAKE SETTINGS
//*******************************************************************************

//-- Force to generate MSXgl static library even if 'msxgl.lib' already exist (boolean)
// BuildLibrary = true;

//-- Prepare program for debug (boolean)
// Debug = false;

//-- Move debug symbols to deployement folder (boolean)
// DebugSymbols = false;

//-- Allow compiler to generate undocumented Z80 instructions (boolean)
AllowUndocumented = true;

//-- Assembler code optimizer (string)
//   - None
//   - Peep       SDCC peep hole otpimizer
//   - MDL        MDL z80 otpimizer
// AsmOptim = "None";

//-- Code optimization priority (string)
//   - Default
//   - Speed
//   - Size
Optim = "Speed";

//-- Code optimization priority (string/integer)
//   - Fast			    2000
//   - Default		    3000
//   - Optimized	   50000
//   - Ultra		  200000
//   - Insane		10000000
CompileComplexity = "Ultra";

//-- Additionnal compilation options (string)
CompileOpt = "--allow-unsafe-read";

//-- Skip file if compile data (REL) is newer than the source code (boolean)
// CompileSkipOld = false;

//-- Additionnal link options (string)
// LinkOpt = "";

//-- Automatic increment of build version in a header file (boolean)
// BuildVersion = false;

//*****************************************************************************
// BUILD TOOL OPTION
//*****************************************************************************

//-- Activate verbose mode and get more build information (boolean)
Verbose = true;

//-- Output build information to the standard console (boolean)
// LogStdout = true;

//-- Output build information to a log file (boolean)
// LogFile = false;

//-- Name of the log file (string)
// LogFileName = "";

//*******************************************************************************
// EMULATOR SETTINGS
//*******************************************************************************

//-------------------------------------------------------------------------------
// General options

EmulMachine    = true;				//-- Force the MSX version of the emulated machine (boolean)
Emul60Hz       = false;				//-- Force the emulated machine to be at 60 Hz (boolean)
EmulFullScreen = false;				//-- Force the emulator to start in fullscreen mode (boolean)
EmulMute       = false;				//-- Disable emulator sound (boolean)
EmulDebug      = false;				//-- Start emulator debugger with program launch (boolean)
EmulTurbo      = false;				//-- Start emulator in turbo mode (boolean)

//-- Emulator extra parameters to be add to command-line (string). Emulator sotfware specific
// EmulExtraParam = "";

//-------------------------------------------------------------------------------
// Extension options

EmulSCC      = false;				//-- Add SCC extension (boolean)
EmulMSXMusic = false;				//-- Add MSX-Music extension (boolean)
EmulMSXAudio = false;				//-- Add MSX-Audio extension (boolean)
EmulOPL4     = false;				//-- Add OPL4 extension (boolean)
EmulPSG2     = false;				//-- Add second PSG extension (boolean)
EmulV9990    = false;				//-- Add V9990 video-chip extension (boolean)

//-------------------------------------------------------------------------------
// Input options

//-- Plug a virtual device into the joystick port A (string)
//   - Joystick
//   - Keyboard         Fake joystick
//   - Mouse
//   - NinjaTap
// EmulPortA = "";

//-- Plug a virtual device into the joystick port B (string)
// EmulPortB = "";
