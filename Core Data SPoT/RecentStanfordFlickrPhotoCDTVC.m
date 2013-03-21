//
//  RecentStanfordFlickrPhotoCDTVC.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/10/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "RecentStanfordFlickrPhotoCDTVC.h"
#import "CoreDataSingleton.h"

@implementation RecentStanfordFlickrPhotoCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        [self setupFetchedResultsController];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useDocument];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Recents";
}

- (void)useDocument
{
    CoreDataSingleton *cds = [CoreDataSingleton getInstance];
    
    [cds openDocumentWithBlock:^(BOOL success) {
        if (success) self.managedObjectContext = cds.document.managedObjectContext;
        else NSLog(@"couldn’t create or open document");
    }];
}

// create a fetch request that looks for photos with accessDate and hook it up through NSFRC
- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"accessDate"
                                                                                     ascending:NO]];
    request.fetchLimit = 10;
    // we dont't photo flagged as deleted
    request.predicate = [NSPredicate predicateWithFormat:@"accessDate != nil AND whereIs.@count != %d", 0];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

@end
