//
//  Tag+Create.h
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/20/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;

@end
