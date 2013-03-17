//
//  CoreDataSingleton.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/13/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "CoreDataSingleton.h"

@implementation CoreDataSingleton

+ (CoreDataSingleton *)getInstance
{
    static dispatch_once_t once = 0;
    __strong static CoreDataSingleton *_instance = nil;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (UIManagedDocument *)document
{
    if (!_document) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"SPoT Database"];
        _document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _document;
}

// opening or creating UIManagedDocument with block
- (void)openDocumentWithBlock:(void (^)(BOOL))block
{
    CoreDataSingleton *cds = [CoreDataSingleton getInstance];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cds.document.fileURL path]]) {
        [cds.document saveToURL:cds.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:block];
    } else if (cds.document.documentState == UIDocumentStateClosed) {
        [cds.document openWithCompletionHandler:block];
    } else {
        block(YES);
    }
}

- (void)saveDocument
{
    CoreDataSingleton *cds = [CoreDataSingleton getInstance];
    [cds.document saveToURL:cds.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
}

@end
