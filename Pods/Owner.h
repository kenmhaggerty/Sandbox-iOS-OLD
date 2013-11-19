//
//  Owner.h
//  Pods
//
//  Created by Ken M. Haggerty on 7/15/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class House;

@interface Owner : NSManagedObject

@property (nonatomic, retain) House *house;

@end
