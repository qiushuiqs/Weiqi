//
//  CalculatorBrain.h
//  Calculater
//
//  Created by Mark Xiong on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void)pushOperand:(double)operand;
-(void)pushVariable:(id)variable;
-(double)performOperation:(NSString *)operator;
-(NSString *)showTheDescription;
-(NSString *)removeLastOperand;


//Program is always guaranteed to be a Property List 

@property (readonly) id program;   //program can be operator or operand,we cannot change the value of that, so it is readonly variable dictionary
@property (nonatomic) NSDictionary *testVariableValues;

+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;    

+(NSString *)descriptionOfProgram:(id)program withVariable:(NSDictionary *)testVariableValues;

+(NSSet *)variablesUsedInProgram:(id)program;

@end
