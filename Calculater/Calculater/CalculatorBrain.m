//
//  CalculatorBrain.m
//  Calculater
//
//  Created by Mark Xiong on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic,strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain
@synthesize programStack= _programStack;
@synthesize testVariableValues = _testVariableValues;

//transfer from radian to angel
#define K 0.017453292519943295769236907684886   

-(NSMutableArray *)programStack{
    if (_programStack==nil) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

//programStack is a local mutable array which push and remove operand. We dont direct calculate according to that array.

-(void)pushOperand:(double)operand{
  //  NSNumber *operandObj = [NSNumber numberWithDouble:operand];       //double to obj
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void)pushVariable:(id)variable{
    [self.programStack addObject:variable];
}

-(NSString *)removeLastOperand{ //remove operand for "undo" action
    if(![CalculatorBrain isOperation:[self.programStack lastObject]]){
        [self.programStack removeLastObject];
    }
    return self.showTheDescription;
}


/*
 Description part of calculator
 Display the operand, variable and operation with the operation rules by recursion.
 */
-(NSString *)showTheDescription{
    return [CalculatorBrain descriptionOfProgram:self.program withVariable:self.testVariableValues];
}

+ (NSString *)descriptionOfProgram:(id)program withVariable:(NSDictionary *)testVariableValues
{
    NSMutableArray *stack;
    NSArray *variableList = [testVariableValues allKeys];
    if([program isKindOfClass:[NSArray class]]){
        stack= [program mutableCopy];
    }
    //partitions of description, insert common between them.
    NSString * token = [self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList];
    while (stack.count>0) {
        token = [[token stringByAppendingString:@","] stringByAppendingString:[self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList]];
    }
    return token;    
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *) stack withVariable:(NSArray *)variableList{
    id topNode = [stack lastObject];
    if(topNode){
        [stack removeLastObject];
    }
    if([topNode isKindOfClass:[NSNumber class]]){
        return  [NSString stringWithFormat:@"%g", [topNode doubleValue]]; 
    }else if ([self isOperation:topNode]) {
        NSString * operation = topNode;     //transfer ID to NSString *
        if ([self isTwoOperandOperation:(operation)]) {
           
            NSString * preAddNumber;  //left binary tree node
            NSString * postAddNumber; //right binary tree node
           
            // If the derivative node is TwoOperandOperator, parentheses them. 
            if([self isTwoOperandOperation:[stack lastObject]]){
                postAddNumber = [[@"("stringByAppendingString:[self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList]] stringByAppendingString:@")"];
            }else {
                postAddNumber = [self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList];
            }
            if([self isTwoOperandOperation:[stack lastObject]]){    
                preAddNumber = [[@"("stringByAppendingString:[self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList]] stringByAppendingString:@")"];
            }else {
                preAddNumber = [self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList];
            }
            
            return [[preAddNumber stringByAppendingString:operation] stringByAppendingString:postAddNumber];
        
        }else if ([self isSingleOperarandOperation:operation]) {
            return [[[topNode stringByAppendingString:@"("] stringByAppendingString:[self descriptionOfTopOfStack:stack withVariable:(NSArray *)variableList]] stringByAppendingString:@")"];
        }
    }else if ([topNode isEqual: @"x"]) {
        NSString* variable = topNode;    //transfer ID to NSString *
        return variable; 
    }
    
    return @"Error";
}

+(BOOL) isTwoOperandOperation:(id) operation{
    NSSet * operationList = [NSSet setWithObjects:@"+",@"-",@"*",@"/",@".",nil];
    if ([operationList containsObject:operation]) return YES;
    else return NO;
}

+(BOOL) isSingleOperarandOperation:(id) operation{
    NSSet * operationList = [NSSet setWithObjects:@"sqrt",@"sin",@"cos", nil];
    if ([operationList containsObject:operation]) return YES;
    return NO;
}


+ (BOOL) isOperation:(NSString *)operation{
    if ([self isSingleOperarandOperation:operation] || [self isTwoOperandOperation:operation]) {
        return YES;
    }else 
    return NO;
}



//made a immitation for programstack and process on the immitation
- (id) program{
    return [self.programStack copy];   //change the mutable array to immutable array
}


/*
 Calculation part of Calculator
 After insert the operation. Run the calculation base on the immitation of orginal stack
 */
-(double)performOperation:(NSString *)operator{
    
    [self.programStack addObject:operator];
    return [CalculatorBrain runProgram:self.program usingVariableValues:self.testVariableValues];
}

+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack= [program mutableCopy];           //make operand stack mutable
        if (variableValues) {           //check variable values and variable in operandstack
            NSSet *variableInStack = [self variablesUsedInProgram:stack];
            if(variableInStack){
                for (int i=0; i<stack.count; i++) {
                    if ([variableInStack containsObject:[stack objectAtIndex:i]]) { //replace to the value from dictionary with identification of key
                        double valueOfVariable = [[variableValues valueForKey:[stack objectAtIndex:i]] doubleValue];
                        [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble: valueOfVariable]];
                    }
                }
            }
        }
    }
    return [self popAllOperand:stack];
}

+(double)popAllOperand:(NSMutableArray *) stack{
    
    double result = 0;
    
    id topNode = [stack lastObject];
    if(topNode){
        [stack removeLastObject];
    }
    
    if ([topNode isKindOfClass:[NSNumber class]]) {
        return [topNode doubleValue];
    }
    if ([topNode isKindOfClass:[NSString class]]){
        NSString * operation = topNode;
        if ([operation isEqualToString:@"+"]) {
            result = [self popAllOperand:stack] + [self popAllOperand:stack];
        }else if ([operation isEqualToString:@"*"]) {
            result = [self popAllOperand:stack] * [self popAllOperand:stack];
        }else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popAllOperand:stack];
            if (divisor) result = [self popAllOperand:stack] / divisor;
                   }else if ([operation isEqualToString:@"-"]){
            double subtrahend = [self popAllOperand:stack];
            result = [self popAllOperand:stack] - subtrahend;
        }else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popAllOperand:stack]);
        }else if ([operation isEqualToString:@"sin"]){
            result = sin([self popAllOperand:stack]*K);
        }else if ([operation isEqualToString:@"cos"]){
            result = cos([self popAllOperand:stack]*K);
        }else if ([operation isEqualToString:@"."]) {
            double numberA = [self popAllOperand:stack];
            double numberB = [self popAllOperand:stack];
            int digit = log10(numberA);
            result = numberB + numberA/(pow(10, digit+1));
        }

    }
    return result;
}

+(NSSet *)variablesUsedInProgram:(id)program{   //achieve all the variable and set them in the NSSet.
    NSMutableSet * variableAppear = [[NSMutableSet alloc] init];
    for (int i=0; i<[program count]; i++) {
        if (!([[program objectAtIndex:i] isKindOfClass:[NSNumber class]] || [self isOperation:[program objectAtIndex:i]]))     
            [variableAppear addObject:[program objectAtIndex:i]];
    }
    return [variableAppear copy];
}



@end
