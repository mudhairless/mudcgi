#Makefile for mudCGI

ifeq ($(OS),DOS)
	TARGET := dos
	$(error error: dos is not supported at this time)
else
	ifeq ($(OS),Windows_NT)
   		TARGET := win32
	else
   		ifdef WINDIR
   			TARGET := win32
		else
       		ifdef windir
       			TARGET := win32
		else
		ifdef HOME
			TARGET := linux
		endif
       		endif
   		endif
	endif
endif

FBC := fbc
CFLAGS := -c -w all -i inc
LFLAGS := -lib -w all

ifndef OPT
	OPT :=
endif

ifndef MAKEDLL
	MAKEDLL := 0
endif

ifeq ($(DEBUG),1)
	CFLAGS += -g
endif

ifeq ($(TARGET),linux)
	DLLX := so
else
	DLLX := dll
endif

ifeq ($(MAKEDLL),1)
	CFLAGS += -export -d MAKEDLL
	LFLAGS += -export -d MAKEDLL
	LIBNAME := lib/$(TARGET)/libmudcgi.$(DLLX)
else
	LIBNAME := lib/$(TARGET)/libmudcgi.a
endif


.PHONY: all

$(LIBNAME) : src/mudcgi.o src/mudcgi-headers.o src/mudcgi-forms.o src/mudcgi-html.o src/mudcgi-response.o src/mudcgi-request.o
	mkdir -p lib/$(TARGET)
	$(FBC) $(LFLAGS) src/mudcgi.o src/mudcgi-headers.o src/mudcgi-forms.o src/mudcgi-html.o src/mudcgi-response.o src/mudcgi-request.o -x $(LIBNAME)

src/mudcgi.o : src/mudcgi.bas inc/mudcgi.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi.bas -o src/mudcgi.o

src/mudcgi-headers.o : src/mudcgi-headers.bas inc/mudcgi.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi-headers.bas -o src/mudcgi-headers.o

src/mudcgi-forms.o : src/mudcgi-forms.bas inc/mudcgi.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi-forms.bas -o src/mudcgi-forms.o

src/mudcgi-html.o : src/mudcgi-html.bas inc/mudcgi/html.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi-html.bas -o src/mudcgi-html.o

src/mudcgi-response.o : src/mudcgi-response.bas inc/mudcgi.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi-response.bas -o src/mudcgi-response.o

src/mudcgi-request.o : src/mudcgi-request.bas inc/mudcgi.bi
	$(FBC) $(CFLAGS) $(OPT) src/mudcgi-request.bas -o src/mudcgi-request.o

clean :
	rm -f src/*.o
	find -name '*~' | xargs rm -f
	rm -f $(LIBNAME)
