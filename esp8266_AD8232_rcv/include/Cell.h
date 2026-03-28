/**
 * @file Cell.h
 * @author youssouf Binyoum
 * @brief Abstract data structure representing Cell data type
 *        A Cell holds a value of uint16_t and a pointer to 
 *        the next Cell.
 * @version 0.1
 * @date 2026-03-25
 * 
 * @copyright Copyright (c) 2026
 * 
 */

 
#pragma once

#include <Arduino.h>

class Cell
{

public:

    Cell (uint16_t value, Cell *next);
    ~Cell();

    inline uint16_t getValue() const {return m_value;}
    inline Cell *getNext() const {return m_nextCellPtr;}

private:

    uint16_t m_value;
    Cell *m_nextCellPtr;
};