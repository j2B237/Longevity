#include <Stack.h>
#include <cassert>


Stack::Stack() : 
    m_size (0),
    m_firstCellPtr (nullptr)
{
    // Empty
}

Stack::~Stack()
{
    m_size = 0;
    m_firstCellPtr = nullptr;
}


void Stack::push(uint16_t value)
{   
    // Check first if the Stack is not full but this is done by the runtime
    m_firstCellPtr = new Cell(value, m_firstCellPtr);
    ++m_size;       
}

uint16_t Stack::top()
{
    // Check first if Stack is not empty
    assert(!this->empty());

    return m_firstCellPtr->getValue();
}

void Stack::pop()
{
    assert(!this->empty());

    // Retrieve a reference to Stakc's top element
    Cell *deleteCell = m_firstCellPtr;

    // Change the current stack'top to the next element of
    // linked list
    m_firstCellPtr = m_firstCellPtr->getNext();

    // Delete the old top
    delete deleteCell;

    --m_size;
}

void Stack::reset()
{
    while (m_firstCellPtr != nullptr){
        this->pop();
    }
}