

# these are the two directories where source code can be located
MEM   = mem-src
SIMULATOR = simulator-src

CC      = gcc
OPTIONS = -O2 -I$(MEM) -I$(SIMULATOR) # Production options
#OPTIONS = -O0 -g -I$(MEM) -I$(SIMULATOR) # Debugging Options
CFLAGS  = $(OPTIONS) -Wall -std=c99 -pedantic -pipe -Werror
SUBMIT  = $(MEM) $(SIMULATOR) Makefile references

MEM_OBJS = page-fault.o \
               page-replacement.o \
               page-lookup.o \
               emat.o \
               tlb-lookup.o

SIMULATOR_OBJS = global.o \
                 memory.o \
                 pagetable.o \
                 process.o \
                 swapfile.o \
                 statistics.o \
                 sim.o \
                 tlb.o

ALL_OBJS = $(MEM_OBJS:%.o=$(MEM)/%.o) \
           $(SIMULATOR_OBJS:%.o=$(SIMULATOR)/%.o)

ALL = vm-sim
all: $(ALL)

vm-sim: $(ALL_OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Use this target to collect all the files to submit to webwork
submit: clean
	tar zcvf p4-submit.tar.gz $(SUBMIT)

.PHONY: clean
clean:
	rm -rf $(ALL) $(MEM)/*.o $(SIMULATOR)/*.o core* $(MEM)/*~

# everything below this line describes the dependencies that exist.
$(SIMULATOR)/global.o: $(SIMULATOR)/global.h $(SIMULATOR)/global.c
$(SIMULATOR)/memory.o: $(SIMULATOR)/memory.h $(SIMULATOR)/memory.c \
                       $(SIMULATOR)/tlb.h    $(SIMULATOR)/statistics.h \
                       $(SIMULATOR)/useful.h $(SIMULATOR)/types.h
$(SIMULATOR)/pagetable.o: $(SIMULATOR)/pagetable.c $(SIMULATOR)/pagetable.h \
                          $(SIMULATOR)/types.h
$(SIMULATOR)/swapfile.o:    $(SIMULATOR)/swapfile.c    $(SIMULATOR)/swapfile.h \
                          $(SIMULATOR)/types.h         $(SIMULATOR)/global.h \
                          $(SIMULATOR)/useful.h        $(SIMULATOR)/statistics.h
$(SIMULATOR)/process.o:   $(SIMULATOR)/process.c   $(SIMULATOR)/process.h \
                          $(SIMULATOR)/global.h    $(SIMULATOR)/useful.h \
                          $(SIMULATOR)/tlb.h       $(SIMULATOR)/pagetable.h \
                          $(SIMULATOR)/types.h
$(SIMULATOR)/sim.o:       $(SIMULATOR)/sim.c        $(SIMULATOR)/global.h \
                          $(SIMULATOR)/process.h    $(SIMULATOR)/memory.h \
                          $(SIMULATOR)/statistics.h $(SIMULATOR)/swapfile.h \
                          $(SIMULATOR)/tlb.h        $(SIMULATOR)/useful.h \
                          $(SIMULATOR)/pagetable.h  $(SIMULATOR)/types.h
$(SIMULATOR)/statistics.o: $(SIMULATOR)/statistics.h $(SIMULATOR)/statistics.c
$(SIMULATOR)/tlb.o: $(SIMULATOR)/tlb.c       $(SIMULATOR)/tlb.h \
                    $(SIMULATOR)/global.h    $(SIMULATOR)/useful.h \
                    $(SIMULATOR)/types.h
$(MEM)/emat.o:  $(SIMULATOR)/statistics.h $(MEM)/emat.c
$(MEM)/page-fault.o: $(SIMULATOR)/types.h    $(SIMULATOR)/process.h \
                         $(SIMULATOR)/global.h   $(SIMULATOR)/swapfile.h \
                         $(MEM)/page-fault.c $(SIMULATOR)/pagetable.h
$(MEM)/page-lookup.o: $(SIMULATOR)/pagetable.h $(MEM)/page-lookup.c \
                          $(SIMULATOR)/swapfile.h    $(SIMULATOR)/statistics.h \
                          $(SIMULATOR)/types.h
$(MEM)/page-replacement.o: $(SIMULATOR)/types.h  $(SIMULATOR)/pagetable.h \
                               $(SIMULATOR)/global.h $(SIMULATOR)/process.h \
                               $(MEM)/page-replacement.c
$(MEM)/tlb-lookup.o: $(MEM)/tlb-lookup.c  $(SIMULATOR)/tlb.h \
                         $(SIMULATOR)/pagetable.h $(SIMULATOR)/types.h

