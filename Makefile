all: hvr.ex5

hvr.ex5: hvr.mq5
	-metaeditor64 /compile:hvr.mq5 /log:log.log
	cat log.log
	rm log.log
