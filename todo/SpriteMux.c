
// definizioni in VRAM
u8 SPT[60][32]

// indice del pattern in VRAM
u16 PatNumSPT[60]
u8  PatFlagSPT[60] // 255 used, 0 free

// indice del pattern associato a ciascuna SAT entry
u16 PAT[32]
u8 	COL[32]

// lista delle definizioni mancanti
u16 MissingSP[32];
u8 NmissSP;

typedef struct {
	u8 y;
	u8 x;
	u8 p;
	u8 c;
} SatEntry;

// Sat in VRAM
SatEntry SAT[32];


//Per ciascun oggetto attivo Nobj
// se è sullo schermo {
//		salva pattern e colore in PAT[i],COL[i]
// 		scrivi in VRAM (y,x)
// }
// il numero di sprite attivi è Nsat<=32

// resetta tutti i flag: PatFlagSPT[i] = 0 con 0<=i<60
//
// Per ciascuno Nsat sprite attivo {
//	cerca PAT[i] in PatNumSPT[60]: 
// 		se è presente alla posizione j (ossia PatNumSPT[j] == PAT[i]) allora
//			scrivi in VRAM che SAT[i].pat = 4*j e segna come usata la entry j (PatFlagSPT[j] = 255)
//		altrimenti se non è presente
//			 aggiung PAT[i] alla lista di definizioni da caricare MissingSP[++NmissSP] = PAT[i];
// }

// Per ciacun i, 0<=i<NmissSP pattern in MissingSP[] 
//	cerca una posizione libera in PatFlagSPT[60]:
//		se è presnete alla posizione j (ossia PatFlagSPT[j] == 0) allora
// 			segnala usata (PatFlagSPT[j] = 255),
//			poni PatNumSPT[j] = MissingSP[i], 
//			carica in VRAM la definizione in SPT[j][]
//			scrivi in VRAM che SAT[i].pat = 4*j





