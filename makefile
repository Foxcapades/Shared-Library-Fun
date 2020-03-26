
build: prep build-c build-d build-go

prep:
	@mkdir -p bin lib shared

build-c:
	@echo "\e[94m"
	@echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
	@echo "┃           Building C Files           ┃"
	@echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
	@echo "\e[0m"

	gcc -shared -o lib/c.so -fPIC c/lib.c
	gcc c/app.c -o bin/c-app -ldl
	cp c/lib.h shared/c.h

build-go:
	@echo "\e[94m"
	@echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
	@echo "┃           Building Go Files          ┃"
	@echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
	@echo "\e[0m"

	go build -o bin/go-app go/main.go
	go build -o lib/go.so -buildmode=c-shared go/lib.go
	mv lib/go.h shared/go.h

build-d:
	@echo "\e[94m"
	@echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
	@echo "┃           Building D Files           ┃"
	@echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
	@echo "\e[0m"

	dmd -c d/lib.d -fPIC -HCf=shared/d.h
	dmd lib.o -shared -oflib/d.so
	dmd -c d/app.d
	dmd app.o -of=bin/d-app
	rm app.o lib.o
