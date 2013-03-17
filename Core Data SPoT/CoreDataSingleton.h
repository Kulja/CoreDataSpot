//
//  CoreDataSingleton.h
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/13/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataSingleton : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

+ (CoreDataSingleton *) getInstance;
- (void)openDocumentWithBlock:(void (^)(BOOL))block;
- (void)saveDocument;

@end
