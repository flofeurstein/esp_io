PORT=/dev/ttyUSB1

load-init:
	python /home/flo/devel/esp8266/tools/luatool/luatool/luatool.py --port $(PORT) --baud 115200 --src lua/init.lua --dest init.lua --restart --delay 0.05 --verbose

load:
	python /home/flo/devel/esp8266/tools/luatool/luatool/luatool.py --port $(PORT) --baud 115200 --src lua/main.lua --dest main.lua --restart --delay 0.05 --verbose --echo

