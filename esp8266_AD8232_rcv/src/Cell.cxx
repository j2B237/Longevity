#include "Cell.h"

Cell::Cell(uint16_t value, Cell *next) :
    m_value (value),
    m_nextCellPtr (next)
{
    // Empty
}

Cell::~Cell()
{
    m_value = 0;
    m_nextCellPtr = nullptr;
}
