//
//  StanfordFlickrSpotCDTVC.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "StanfordFlickrSpotCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Tag.h"
#import "CoreDataSingleton.h"

@implementation StanfordFlickrSpotCDTVC

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
    //self.debug = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"SPoT";
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotosFromFlickr) forControlEvents:UIControlEventValueChanged];
}

- (void)useDocument
{
    CoreDataSingleton *cds = [CoreDataSingleton getInstance];
    
    [cds openDocumentWithBlock:^(BOOL success) {
        if (success) self.managedObjectContext = cds.document.managedObjectContext;
        else NSLog(@"couldn’t create or open document");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.fetchedResultsController.fetchedObjects count] == 0) {
                [self loadStanfordPhotosFromFlickr];
            }
        });
    }];
}

- (void)loadStanfordPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t stanfordPhotoLoaderQ = dispatch_queue_create("stanford photo loader", NULL);
    dispatch_async(stanfordPhotoLoaderQ, ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *arrayOfStanfordPhotos = [FlickrFetcher stanfordPhotos];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *flickrInfo in arrayOfStanfordPhotos) {
                [Photo photoWithFlickrInfo:flickrInfo inManagedObjectContext:self.managedObjectContext];
            }
            
            // explicit saving 
            [[CoreDataSingleton getInstance] saveDocument];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

// Create an NSFetchRequest to get all tags and hook it up to our table via an NSFetchedResultsController
- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = nil; // all tags
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

// loads up a table view cell with the spot name and number of photos in that spot at the given row in the Model
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Tag"];
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    cell.textLabel.text = tag.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
    
    return cell;
}

// prepares for the "Show Photos in Spot" segue by seeing if the destination view controller of the segue
//  understands the method "setSpot:"
// if it does, it sends setSpot: to the destination view controller with
//  the NSArray of NSDictionaries of the spot that was selected in the UITableView as the argument
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.identifier isEqualToString:@"Show Photos in Tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                    [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
                }
            }
        }
    }
}

@end
