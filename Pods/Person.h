//
//  Person.h
//  Pods
//
//  Created by Ken M. Haggerty on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Owner.h"

@class Person;

@interface Person : Owner

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Person *parent;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Person *)value;
- (void)removeChildrenObject:(Person *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
