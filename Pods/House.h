//
//  House.h
//  Pods
//
//  Created by Ken M. Haggerty on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owner;

@interface House : NSManagedObject

@property (nonatomic, retain) Owner *owner;

@end
