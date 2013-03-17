//
//  StanfordFlickrPhotoCDTVC.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "StanfordFlickrPhotoCDTVC.h"
#import "Photo+Flickr.h"
#import "ImageViewController.h"
#import "CoreDataSingleton.h"

@interface StanfordFlickrPhotoCDTVC () <UISplitViewControllerDelegate, UISearchBarDelegate>
@end

@implementation StanfordFlickrPhotoCDTVC

// create a fetch request that looks for spot with the given name and hook it up through NSFRC
- (void)setupFetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSString *sortDescriptorWithKey = @"title";
    NSString *sectionNameKeyPath = @"section";
    if ([self.spot.title isEqualToString:@"All"]) {
        sortDescriptorWithKey = @"whereIs.title";
        sectionNameKeyPath = @"whereIs.title";
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"whereIs = %@", self.spot];
    }
    
    if (predicate) request.predicate = predicate;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortDescriptorWithKey
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.spot.managedObjectContext
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:nil];
}

// update our title and set up our NSFRC when our Model is set
- (void)setSpot:(SPoT *)spot
{
    _spot = spot;
    self.title = spot.title;
    if (self.spot.managedObjectContext) {
        [self setupFetchedResultsControllerWithPredicate:nil];
        
        // hide searchbar (you can see it by scrolling up)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo"];
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnailImageData];

    if (!cell.imageView.image) {
        dispatch_queue_t q = dispatch_queue_create("Thumbnail Flickr Photo", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.squareImageURL]];
            [photo.managedObjectContext performBlock:^{
                [Photo insertThumbnailImageData:imageData forPhoto:photo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsLayout];
                });
            }];
        });
    }

    return cell;
}

// delete photo
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [photo.managedObjectContext performBlock:^{
            [Photo flagPhotoAsDeleted:photo];
            [[CoreDataSingleton getInstance] saveDocument];
        }];
    }
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        NSPredicate *predicate = nil;
        if ([self.spot.title isEqualToString:@"All"]) {
            predicate = [NSPredicate predicateWithFormat:@"(subtitle contains[cd] %@) OR (title contains[cd] %@)", searchText, searchText];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"(subtitle contains[cd] %@) OR (title contains[cd] %@) AND (whereIs = %@)", searchText, searchText, self.spot];
        }
        [self setupFetchedResultsControllerWithPredicate:predicate];
    } else {
        [self setupFetchedResultsControllerWithPredicate:nil];
    }
    
    [self performFetch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Segue

// typical “setSplitViewBarButton:” method
- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    
                    NSURL *imageURL = [NSURL URLWithString:photo.largeImageURL];
                    if ([self splitViewDetailWithBarButtonItem]) {
                        [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
                        imageURL = [NSURL URLWithString:photo.originalImageURL];
                    }

                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:imageURL];
                    [segue.destinationViewController setTitle:photo.title];
                    // set the date of access
                    [photo.managedObjectContext performBlock:^{
                        [Photo setAccessDateForPhoto:photo];
                        
                        // explicit saving
                        [[CoreDataSingleton getInstance] saveDocument];
                    }];
                }
            }
        }
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    // add the bar button from its toolbar
    barButtonItem.title = @"Images";
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)sender willShowViewController:(UIViewController *)master invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove the bar button from its toolbar
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
}

@end
