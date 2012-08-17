//
//  ViewController.m
//  KivaJSONDemo
//
//  Created by Mark Xiong on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString: @"http://api.kivaws.org/v1/loans/search.json?status=fundraising"] //2


#import "ViewController.h"


@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data 
                                                options:kNilOptions 
                                                  error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self 
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:kLatestKivaLoansURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) //remember that you can only access UIKit objects from the main thread, which is why we had to run fetchedData: on the main thread.
                               withObject:data 
                            waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data...and If you’re parsing large JSON feeds (which is often the case), be sure to do that in the background.
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData //we get an NSDictionary from the JSON data
                          options:kNilOptions//NSJSONReadingMutableContainers: Good if you want to add things to the containers after parsing it. 
                          error:&error];
    
    NSArray* latestLoans = [json objectForKey:@"loans"]; //we get an NSArray latestLoans which is the loans key in the top JSON dictionary.
    
    NSLog(@"loans: %@", latestLoans);
    
//json data ------> Human language    
    // 1) Get the latest loan
    NSDictionary* loan = [latestLoans objectAtIndex:1];
    
    // 2) Get the funded amount and loan amount
    NSNumber* fundedAmount = [loan objectForKey:@"funded_amount"];
    NSNumber* loanAmount = [loan objectForKey:@"loan_amount"];
    float outstandingAmount = [loanAmount floatValue] - 
    [fundedAmount floatValue];
    
    // 3) Set the label appropriately
    humanReadble.text = [NSString stringWithFormat:@"Latest loan: %@from %@ needs another $%.2f to pursue their entrepreneural dream",
                         [loan objectForKey:@"name"],
                         [(NSDictionary*)[loan objectForKey:@"location"] 
                          objectForKey:@"country"],
                         outstandingAmount];
       
    //build an info object and convert to json
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [loan objectForKey:@"name"], 
                          @"who",
                          [(NSDictionary*)[loan objectForKey:@"location"] 
                           objectForKey:@"country"], 
                          @"where",
                          [NSNumber numberWithFloat: outstandingAmount], 
                          @"what",
                          nil];
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info //kNilOptions produce compact JSON code for sending to Server over internet. 
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    //print out the data contents
    jsonSummary.text = [[NSString alloc] initWithData:jsonData                                        
                                             encoding:NSUTF8StringEncoding];
   
    
}


@end