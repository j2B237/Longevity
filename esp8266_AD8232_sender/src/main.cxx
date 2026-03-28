/**
 * @file main.cxx
 * @author youssouf Binyoum
 * @brief Program that ECG Data using ESP-NOW protocol COM
 * @version 0.1
 * @date 2026-03-26
 * 
 * @copyright Copyright (c) 2026
 * 
 */

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <espnow.h>
#include <Ticker.h>

#include <Stack.h>

#define LO_MOINS 4
#define LO_PLUS  5

/* ====== Globales Objects ====== */

// mac address is about 48 bits (6 bytes) expressed in hexadecimal format. 
uint8_t rcvMacAddress[] = {0x08, 0x3A, 0x8D, 0xE3, 0xB2, 0x41};
//uint8_t rcvMacAddress[] = {0x08, 0x3A, 0x8D, 0xE3, 0xBD, 0x0E};


// Data struct to store ECG Data before sending
volatile static ECG_t buffer = {};

// Flag for synchronization
volatile bool dataReady = false;

volatile uint16_t lastEcgValue = 0;
volatile bool newSampleReady = false;

Stack ecgStack;

// Two differents : once for Sending data every 500 ms 
// and another for sampling AD8232 every 5 ms (200 Hz)

Ticker senderTicker;
Ticker samplerTicker;

uint16_t val;

/* ===== ISR : Interrupt Service Routime ===== */

/**
 * @brief CPU call routine that run its instructions
 * every 600 ms.  
 * 
 */
void
onTimingReach()
{
    if (ecgStack.size() >= 120){
        dataReady = true;
    }
}

/**
 * @brief ISR call every 5 ms to read ADC
 * 
 */
void 
onSampleTick()
{
    // 1. Lire la valeur (très rapide)
    /*if (digitalRead(LO_MOINS) == 0 && digitalRead(LO_PLUS) == 0) {
        lastEcgValue = (uint16_t)analogRead(A0);
        newSampleReady = true; 
    }*/
    lastEcgValue = (uint16_t)analogRead(A0);
    newSampleReady = true; 
}
/* ====== Functions prototypes ======== */

void
onDataSend (uint8_t *macAddress, uint8_t status);


void
setup()
{
    //===============================
    // Serial monitor configuration 
    //===============================

    Serial.begin (115200);
    Serial.println();

    // ============================
    // Interrupt initialization
    // ============================

    // Send 100 samples 5ms x 100 = 500 ms

    senderTicker.attach  (0.51, onTimingReach);
    samplerTicker.attach (0.005, onSampleTick);

    //===========================
    // WiFi configuration 
    //===========================

    WiFi.mode (WIFI_STA);
    WiFi.disconnect ();                     // Important before starting ESP-NOW

    //===========================
    // ESP-NOW Configuration 
    //===========================

    if(esp_now_init() != 0){
        Serial.println("esp_now_init() failed\n");
        return;
    }

    // Define board role
    int addRole = esp_now_set_self_role (ESP_NOW_ROLE_CONTROLLER);
    Serial.println(addRole == 0 ? "Role set successfully\n" : "Failed to set role\n");

    // Add peer using his mac address
    int addStatus = esp_now_add_peer (rcvMacAddress, ESP_NOW_ROLE_SLAVE, 1, NULL, 0);
    Serial.println(addRole == 0 ? "Successfully pairing\n" : "Pairing failed\n");

    // Register acknowledge callback function
    int regStatus = esp_now_register_send_cb ((esp_now_send_cb_t)onDataSend);
    Serial.println(regStatus == 0 ? "Function registered successfully\n" : "Failed to register\n");

    /* ==== GPIO Configuration ======= */
    pinMode (LO_MOINS, INPUT);
    pinMode (LO_PLUS, INPUT);

}


void
loop()
{
    // 1. Faked data acquisition
    if (newSampleReady){
        newSampleReady = false;
        ecgStack.push(lastEcgValue);
    }

    // 2. Data transfert over ESP-NOW
    if (dataReady){

        // Copy data from stack into outcome buffer
        for (uint8_t j = 0; j < 120; j++){
            buffer.data[j] = ecgStack.top();
        }

        int result = esp_now_send (rcvMacAddress, (uint8_t*)&buffer, sizeof(buffer));
        //Serial.println(result == 0 ? "Data successfully copy into buffer\n" : "Failed to copy data\n");
        
        ecgStack.reset();
        dataReady = false;
    }

    yield(); // LAISSE DU TEMPS AU SYSTÈME (IMPORTANT)
}


/* ======= Functions definitions ========= */
void
onDataSend (uint8_t *macAddress, uint8_t status)
{
    Serial.printf("Stack's size = %u\n", ecgStack.size());
    Serial.println ("\r\nStatus of last sent packet....");
    Serial.printf (status == 0 ? "Success\n" : "Failed\n");
}
