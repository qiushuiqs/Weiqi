#import "ObjectiveCAdaptor.h"
#include "CPlusPlusClass.h"

@implementation ObjectiveCAdaptor

- (id) init {
    if (self = [super init]) {
        testObj = new CPlusPlusClass();
    }
    
    return self;
}

- (void) dealloc {
    if (testObj != NULL) {
        delete testObj;
        testObj = NULL;
    }
    [super dealloc];
}

- (void) objectiveFunc
{
    testObj->setInt(5);
    testObj->func();
}  
    @end
  