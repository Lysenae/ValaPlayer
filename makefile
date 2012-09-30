PROGRAM = player

SRC = main.vala gui.vala streamer.vala tracklist.vala tagreader.vala trackinfo.vala helpers.vala playbackpositioner.vala abstractview.vala

PKGS = --pkg gtk+-3.0 --pkg gdk-pixbuf-2.0 --pkg gstreamer-0.10 --pkg pango --pkg gdk-3.0

VALAC = valac

BUILD_ROOT = 1

all:
	@$(VALAC) $(SRC) -o $(PROGRAM) $(PKGS)
  
release: clean
	@$(VALAC) -X -O2 $(SRC) -o stream_player $(PKGS)
  
clean:
	@rm -v -fr *~ *.c $(PROGRAM)   
