//
//  CPlusPlusClass.mm
//  SpeakHere
//
//  Created by Mark Xiong on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include "CPlusPlusClass.h"

CPlusPlusClass::CPlusPlusClass() : m_i(0) 
{
    printf("CPlusPlusClass::CPlusPlusClass()\n");
    func();
}

CPlusPlusClass::~CPlusPlusClass() 
{
    printf("CPlusPlusClass::~CPlusPlusClass()\n");
}

void CPlusPlusClass::func() {
    printf("CPlusPlusClass func print: %d\n", m_i);
}