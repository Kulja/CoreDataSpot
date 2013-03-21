//
//  Tag+Create.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/20/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Tag *tag = nil;
    
    // see if a tag with this title is already in the databasse
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error];
    
    if (!tags || ([tags count] > 1)) {
        // error handling
        NSLog(@"Error in Tag");
    } else if (![tags count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.title = title;
    } else {
        tag = [tags lastObject];
    }
    
    return tag;
}

@end
