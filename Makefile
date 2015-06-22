include common.mk

#ls -d */ | sed -e 's,//$,,' -e 's,doc,,' -e 's,lib,,'  -e 's,include,,' | xargs
SOURCE_DIR	= utilities source atmosphere imaging centroiding shackHartmann aaStats BTBT GBTBT iterativeSolvers LMMSE plotly rayTracing# system
TUTORIAL	= ngsao lgsao ltao ltaoVsAst geaos
PYTHON_DIR	= utilities source atmosphere centroiding imaging shackHartmann aaStats GBTBT LMMSE rayTracing
CYTHON_DIR	= utilities rayTracing source imaging centroiding shackHartmann atmosphere LMMSE aaStats

all: makefile jsmnlib
ifeq ($(wildcard include/plotly.credentials), )
	echo "plotly.credentials doesn't exist!"
	cp include/plotly.credentials.sample include/plotly.credentials
else
	echo "plotly.credentials does exist!"
endif
	mkdir -p include lib
	for i in $(SOURCE_DIR); do (make -C $$i src);echo -e "\n"; done
	for i in $(SOURCE_DIR); do (make -C $$i lib);echo -e "\n"; done

tex: makefile $(texsrc)
	for i in $(SOURCE_DIR); do (make -C $$i tex); done
	for i in $(TUTORIAL); do (make -C TUTORIAL $$i.tex); done
	rm -f doc/ceo.manual.main.tex
	for i in $(SOURCE_DIR); do (echo -e "\input{ceo.manual.$$i}\n">>doc/ceo.manual.main.tex); done
	for i in $(SOURCE_DIR); do (echo -n "\chapter" >doc/ceo.manual.$$i.tex; echo -e "{$$i}\n\label{sec:$$i}\n\n\input{../$$i/$$i}">>doc/ceo.manual.$$i.tex); done


cython: makefile
#	for i in $(CYTHON_DIR); do (make -C $$i cython); done
	for i in $(CYTHON_DIR); do (make -C $$i cysrc);echo -e "\n"; done
	for i in $(CYTHON_DIR); do (make -C $$i cylib);echo -e "\n"; done

doc: tex
	make -C doc all

ripython:
	env PYTHONPATH="$(CEOPATH)/python" ipython notebook --no-browser

touch: 
	find . -name \*.nw -exec touch {} \;

makefile: Makefile.common
	for i in $(SOURCE_DIR); do (cp Makefile.common $$i/Makefile; sed -i -e "s/filename/$$i/g" $$i/Makefile); done

jsmnlib: 
	mkdir -p include lib
	make -C jsmn
	cp -P jsmn/jsmn.h include/
	cp -P jsmn/libjsmn.a lib/


clean_makefile:
	for i in $(SOURCE_DIR); do (rm -f $$i/Makefile); done

clean:
	for i in $(SOURCE_DIR); do (make -C $$i clean); done
	rm -f *.*~
	rm -f lib/libceo.a

cleanbins: makefile
	for i in $(SOURCE_DIR); do (make -C $$i cleanbins); done
