#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <FastLED.h>

#define SLAVE_ADDRESS 4
#define NUM_LEDS 24
#define DATA_PIN 12
#define MAX_BRIGH 128
#define LOW_BRIGH 16

CRGB leds[NUM_LEDS];
SoftwareSerial BTSerial(10, 11);

int val, index=0, soll=0, pick_count = 0, led_index = 14, send_count = 0, gesamt = 0;
boolean acting = false, ring = false;
char input[7] = {'0','0','0','0','0','0','0'};
char output[8] = {'X','0','0','0','0','0','0','0'};

//led functions
void fadeall() {for(int i = 0; i < NUM_LEDS; i++) {leds[i] = CRGB::Black;} FastLED.show();}
void greenall() {for(int i = 0; i < NUM_LEDS; i++) {leds[i] = CRGB::Green;} FastLED.show();}
void redall() {for(int i = 0; i < NUM_LEDS; i++) {leds[i] = CRGB::Red;} FastLED.show();}
void orangeall() {for(int i = 0; i < NUM_LEDS; i++) {leds[i] = CRGB::Orange;} FastLED.show();}
void blueall() {for(int i = 0; i < NUM_LEDS; i++) {leds[i] = CRGB::Blue;} FastLED.show();}
void brightness(int x) {FastLED.setBrightness(x);}
void blink(int color) {
	brightness(MAX_BRIGH);
	for(int i = 0; i<3; ++i){
		switch (color){
			//green
			case 0:{greenall(); break;}
			//red
			case 1:{redall(); break;}
			//orange
			case 2:{orangeall(); break;}
			//blue
			case 3:{blueall(); break;}
			default:{break;}
		}
		delay(100);
		fadeall();
		delay(100);
	}
	brightness(LOW_BRIGH);
}
void redring(int led) {
	//Rotierender Roter Ring
	if(leds[led]){
		leds[led] = CRGB::Black;
	} else {
		leds[led] = CRGB::Red;
	}
	FastLED.show();
	led_index++;
	delay(50);
}
void bluering(int led) {
	//Rotierender Roter Ring
	if(leds[led]){
		leds[led] = CRGB::Black;
	} else {
		leds[led] = CRGB::Blue;
	}
	FastLED.show();
	led_index++;
	delay(50);
}
void greenring(int segment, boolean on) {
	if(on){
		switch(segment){
		case 1:
			for(int i = 14; i<21; ++i){
				leds[i%NUM_LEDS] = CRGB::Green;
			}
			break;
		case 2:
			for(int i = 20; i<26; ++i){
				leds[i%NUM_LEDS] = CRGB::Green;
			}
			break;
		case 3:
			for(int i = 2; i<8; ++i){
				leds[i%NUM_LEDS] = CRGB::Green;
			}
			break;
		case 0:
			for(int i = 8; i<14; ++i){
				leds[i%NUM_LEDS] = CRGB::Green;
			}
			break;
		default:
			break;
		}
	} else {
		switch(segment){
		case 1:
			for(int i = 14; i<21; ++i){
				leds[i%NUM_LEDS] = CRGB::Black;
			}
			break;
		case 2:
			for(int i = 20; i<26; ++i){
				leds[i%NUM_LEDS] = CRGB::Black;
			}
			break;
		case 3:
			for(int i = 2; i<8; ++i){
				leds[i%NUM_LEDS] = CRGB::Black;
			}
			break;
		case 0:
			for(int i = 8; i<14; ++i){
				leds[i%NUM_LEDS] = CRGB::Black;
			}
			break;
		default:
			break;
		}
	}
	FastLED.show();
}

//reset all vars
void reset(){
	val = 0;
	index = 0;
	soll = 0;
	gesamt = 0;
	pick_count = 0;
	led_index = 14;
	send_count = 0;
	output[0] = 'X';
	acting = false;
}

//erledigt Bluetooth kram
void readBluetooth() {
	//liest Bluetooth verbindung aus und speichert die Werte ab.
	while(BTSerial.available()){
		int x = BTSerial.read();
		if(x == 88 || x == 89){
			fadeall();
			if(x==89){
				ring = true;
				return;
			}
			ring = false;
			return;
		}
		input[index] = char(x);
		gesamt += int(x);
		index++;
	}
	//wenn 7 zeichen empfangen wurden ist der Array vollständig und der erste Wert wird angepasst.
	if((unsigned) index>sizeof(input)-1){
		index = 0;
		for(char a:input){
			output[index + 1] = a;
			index++;
		}
		index = 0;
		output[0] = char(soll+48);
		output[1] = char(gesamt+48);
		BTSerial.write("received");
		Serial.print("Array: ");for(int i = 0; (unsigned)i<sizeof(input); ++i){Serial.print(input[i]);}Serial.print("\n");
		blink(2);
	}
}

//überprüfung des empfangenen
void act(int value){
	if(value!=0){
		switch(value){
			//start Mindstorm/start Programm
			case 1:
			case 8:
			case 16:
				{	
					BTSerial.write("restart");
					reset();
					ring = false;
					fadeall();
					break;
				}
			//Mindstorm fährt los
			case 2:
				{
					if(!acting){
						BTSerial.write("start");
						blink(3);
						reset();
					}
					acting = true;
					break;
				}
			//Mindstorm hat Array abgefragt, und nix gefunden
			case 3:
				{
					blink(1);
					break;
				}
			case 9:
				{
					fadeall();
					for (int i = 0; i < gesamt; i++)
					{
						greenring(4-i, true);
					}
					break;
				}
			case 10:
				{
					gesamt--;
					greenring(4-gesamt, false);
				}
			//Mindstorm hat Reagenzglas aufgehoben
			case 20:
				{
					acting = true;
					pick_count++;
					BTSerial.write(char(pick_count + 48));
					greenring(pick_count%4, true);
					break;
				}
			//Mindstorm ist fertig
			case 100:
			case 101:
				{	
					if(acting){
						BTSerial.write("finished");
						blink(3);
					}
					fadeall();
					reset();
					break;
				}
			//Arduino hat irgendwas Komisches bekommen
			default:
				{
					Serial.println(value);
					break;
				}
		}
		val = 0;
	}
}

//Wenn der Mindsotrm was sendet
void receiveI2C(int bytesIn)
	{
		while(1 < Wire.available()){}
		int x = Wire.read();
		Serial.println(x);
		val = x;
	}

//Wenn der Mindstorm Daten will
void sendData()
{
  Wire.write(output,8);
}

//setup
void setup() 
{
    Serial.begin(9600);
    BTSerial.begin(9600);

    Wire.begin(SLAVE_ADDRESS);
    Wire.onReceive(receiveI2C);
    Wire.onRequest(sendData);

    FastLED.setBrightness(LOW_BRIGH);
    FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
}
 
//loop
void loop()
{
	act(val);

	if(!acting){
		if(!ring){
			bluering(led_index%NUM_LEDS);
		} else {
			redring(led_index%NUM_LEDS);
		}
		if(BTSerial.available()) {
			readBluetooth();
		}
	}
}