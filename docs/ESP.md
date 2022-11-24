## Install esptool

python3 -m pip install --upgrade pip
python3 -m pip install esptool

### Find esp8266 device

ls /dev/tty.*

### Erase

python3 -m esptool --port <PORT> erase_flash

### Update firmware

python3 -m esptool -p <PORT> -b 115200 write_flash 0 <PATH_TO_FIRMWARE>

#### Example

python3 -m esptool -p /dev/tty.usbserial-0001 -b 115200 write_flash 0 esp8266_firmware.bin