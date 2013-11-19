//
//  Employee.h
//  Pods
//
//  Created by Ken M. Haggerty on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Person.h"

@class Company;

@interface Employee : Person

@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) Company *company;

@end
