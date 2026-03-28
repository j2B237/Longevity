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

Stack ecgStack;
Ticker senderTicker;

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

/* ====== Functions prototypes ======== */

void
onDataSend (uint8_t *macAddress, uint8_t status);

void
collectECGData();


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

    senderTicker.attach (0.50, onTimingReach);

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
    //collectECGData();
    val = (uint16_t)analogRead(A0);
    ecgStack.push(val);
    delay (1);

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
        
        yield(); // LAISSE DU TEMPS AU SYSTÈME (IMPORTANT)
    }
    
}


/* ======= Functions definitions ========= */
void
onDataSend (uint8_t *macAddress, uint8_t status)
{
    Serial.println ("\r\nStatus of last sent packet....");
    Serial.printf (status == 0 ? "Success\n" : "Failed\n");
}

void
collectECGData()
{
    if (digitalRead (LO_MOINS) == 1 || digitalRead (LO_PLUS) == 1){
        // Do nothing
    }
    else{
        val = (uint16_t)analogRead(A0);
        ecgStack.push(val);
        //delay (5);
    }
}