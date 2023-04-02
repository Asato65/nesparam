FILENAME = smb1
ASMFILE = $(FILENAME).asm
OBJFILE = $(FILENAME).o
NESFILE = $(FILENAME).nes
DBGFILE = $(FILENAME).dbg
CFGFILE = /.vscode/sample1.cfg
ASSEMBLER = ca65
LINKER = ld65
EMULATOR = Mesen

all : clean build play

build : $(NESFILE) $(OBJFILE)

play : $(NESFILE)
	$(EMULATOR) $(NESFILE)

clean :
	-rm $(OBJFILE) $(DBGFILE)
	-del $(OBJFILE) $(DBGFILE)

$(OBJFILE) : $(ASMFILE)
	$(ASSEMBLER) $(ASMFILE) -g

$(NESFILE) : $(OBJFILE)
	$(LINKER) -t nes --dbgfile $(DBGFILE) --cfg-path $(CFGFILE) -o $(NESFILE) $(OBJFILE)
