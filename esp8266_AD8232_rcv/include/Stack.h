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
typedef struct ECG_t {
    uint16_t data[120];   // 120 x 2 = 240 octets for security   
}ECG_t;


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