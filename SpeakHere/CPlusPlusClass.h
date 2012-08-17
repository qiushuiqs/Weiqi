//
//  CPlusPlusClass.h
//  SpeakHere
//
//  Created by Mark Xiong on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SpeakHere_CPlusPlusClass_h
#define SpeakHere_CPlusPlusClass_h

class CPlusPlusClass {
public:
    CPlusPlusClass();
    virtual ~CPlusPlusClass();
    void func();
    void setInt (int i) {
        m_i = i;
    }
    
private:
    int m_i;
};

#endif
