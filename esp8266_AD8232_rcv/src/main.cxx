/**
 * @file main.cxx
 * @author youssouf Binyoum
 * @brief Program using ESP-NOW protocole to send ECG Data.
 *         . The program is running on an Esp8266 (SLAVE)
 * @version 0.1
 * @date 2026-03-24
 * 
 * @copyright Copyright (c) 2026
 * 
 */

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <espnow.h>

#include <Stack.h>

/* ==== Custom data type ===== */


/* ===== GLobales variables ===== */

ECG_t buffer;

/* ===== Functions prototypes ===== */

void
getMacAddress();

void
onDataRcv(const uint8_t *macAddress, const uint16_t *incomingData, int len);


void
setup()
{
    // Serial monitor config
    Serial.begin (115200);
    Serial.println();

    delay(500);     // 500 ms

    // ===================
    // Wfi configuration
    // ===================

    WiFi.mode (WIFI_STA);           // Mode station
    //getMacAddress();
    //delay (500);
    WiFi.disconnect();

    // =====================
    // ESP-NOW configuration
    // =====================

    if(esp_now_init () != 0){
        Serial.println("esp_now_init() failed\n");
        return;
    }

    int roleStatus = esp_now_set_self_role (ESP_NOW_ROLE_SLAVE);
    Serial.println(roleStatus == 0 ? "Role successfully set\n" : "Failed to set role\n");
    
    // Register the receiver callback function
    esp_now_register_recv_cb ((esp_now_recv_cb_t)onDataRcv);

}


void
loop()
{
    yield();
}

/* ========= Function defintion ======== */

void
getMacAddress()
{
    String macAddress = WiFi.macAddress();
    Serial.printf("Receiver Mac Address : %s\n", macAddress.c_str());
}


void
onDataRcv(const uint8_t *macAddress, const uint16_t *incomingData, int len)
{
    memcpy (&buffer, incomingData, sizeof(buffer));

    Serial.println("Received:\r\n");
    for (uint8_t i = 0; i < 120; i++){
        Serial.println(buffer.data[i]);
    }
    Serial.println();
}