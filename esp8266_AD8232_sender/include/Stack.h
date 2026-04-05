/**
 * @file Stack.h
 * @author youssouf Binyoum
 * @brief 
 * @version 0.1
 * @date 2026-03-25
 * 
 * @copyright Copyright (c) 2026
 * 
 */

#pragma once

#include <Arduino.h>
#include "Cell.h"

/**
 * @brief AD8232 High resolution is 10-bit.
 * ADC convert from 0 to 1023. So we use 2 byte
 * per value.
 * ESP-NOW max playload is 250 = 125 x 2 therefore
 * we can send 125 values inside a frane
 * 
 */
typedef struct  __attribute__((packed)) {
    uint16_t data[120];   // 120 x 2 = 240 octets for security   
}ECG_t;

/**
 * @brief 
 * uint32_t startTime;    // micros() du premier échantillon
 * uint16_t interval;     // Temps entre deux points en micros (ex: 5000 pour 200Hz)
 * uint16_t count;        // Nombre de points réellement envoyés (ex: 120)
 * uint16_t data[x];    // Les valeurs brutes de l'ADC
 * 
 */
typedef struct __attribute__((packed)){
    uint32_t magic;         // Mettre 0xDEADBEEF
    uint32_t startTime;    // micros() du premier échantillon 
    uint16_t interval;     // Temps entre deux points en micros (ex: 5000 pour 200Hz)
    uint16_t count;        // Nombre de points réellement envoyés (ex: 120)
    uint16_t data[100];    // Les valeurs brutes de l'ADC
}ECG_Packet_t;


class Stack 
{
public:
    /* [Constructor]*/
    Stack ();
    ~Stack();

    /*[Public methods]*/

    void push (uint16_t value);
    void pop ();
    void reset();
    
    /* [Getter / Setter]*/
    uint16_t top();
    inline uint8_t size() const {return m_size;}
    inline bool empty() const {return m_firstCellPtr == nullptr; }

private:
    uint8_t m_size;
    Cell *m_firstCellPtr;
};