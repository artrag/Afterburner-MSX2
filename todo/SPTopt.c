
Crea Lista_Frame_in_VRAM: 
	Per ogni FrameNum -> SPT ENTRY IN VRAM
	
Creal Lista_Sprite_inVRAM:
	Per ogni PatterNum -> SPT Entry IN VRAM

SetObjFrame(ObjNum,FrameNum) {	

	Rimuovi da Lista_Frame_in_VRAM la precedente FrameNum per ObjNum

	Se FrmNum è già presnete in  Lista_Frame_in_VRAM:
	    Fai puntare ObjNum alla SPT ENTRY IN VRAM
	altrimenti
		Cerca Nsp posizioni libere in SPT IN VRAM
		Carica in VRAM le Nsp definizioni 
		Aggiorna la Lista_Frame_in_VRAM
		Fai puntare ObjNum alla SPT ENTRY IN VRAM
}