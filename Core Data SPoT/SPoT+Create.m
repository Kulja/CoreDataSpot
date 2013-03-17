//
//  SPoT+Create.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "SPoT+Create.h"

@implementation SPoT (Create)

+ (SPoT *)spotWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context
{
    SPoT *spot = nil;
    
    // see if a spot with this name is already in the databasse
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SPoT"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *spots = [context executeFetchRequest:request error:&error];
    
    if (!spots || ([spots count] > 1)) {
        // error handling
        NSLog(@"error");
    } else if (![spots count]) {
        spot = [NSEntityDescription insertNewObjectForEntityForName:@"SPoT" inManagedObjectContext:context];
        spot.title = title;
    } else {
        spot = [spots lastObject];
    }
    return spot;
}

+ (void)deleteSpotIfEmpty
{
    
}

@end
