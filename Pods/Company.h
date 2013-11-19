//
//  Company.h
//  Pods
//
//  Created by Ken M. Haggerty on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Owner.h"

@class Employee;

@interface Company : Owner

@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSSet *employees;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addEmployeesObject:(Employee *)value;
- (void)removeEmployeesObject:(Employee *)value;
- (void)addEmployees:(NSSet *)values;
- (void)removeEmployees:(NSSet *)values;

@end
