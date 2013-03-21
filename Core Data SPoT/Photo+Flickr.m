//
//  Photo+Flickr.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

+ (NSArray *)getTitleOfTagsForImage:(NSDictionary *)imageInfo
{
    // getting FLICKR_TAGS out of our image and formating it to our needs
    NSArray *tempArray = [[imageInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
    NSArray *arrayOfTags = [NSArray array];
    
    arrayOfTags = [arrayOfTags arrayByAddingObject:@"All"];
    for (NSString *tag in tempArray) {
        if (![tag isEqualToString:@"cs193pspot"] && ![tag isEqualToString:@"portrait"] && ![tag isEqualToString:@"landscape"]) {
            arrayOfTags = [arrayOfTags arrayByAddingObject:[tag capitalizedString]];
        }
    }
    
    return arrayOfTags;
}

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [[flickrInfo objectForKey:FLICKR_PHOTO_ID] description]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    if (!photos || ([photos count] > 1)) {
        // error handling
        NSLog(@"Error in Photo");
    } else if (![photos count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [[flickrInfo objectForKey:FLICKR_PHOTO_ID] description];
        photo.title = [[flickrInfo objectForKey:FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [[flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.section = [[[flickrInfo objectForKey:FLICKR_PHOTO_TITLE] description] substringToIndex:1];
        photo.squareImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatSquare] absoluteString];
        photo.largeImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.originalImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatOriginal] absoluteString];
        
        NSSet *setOfTags = [NSSet set];
        for (NSString *tag in [self getTitleOfTagsForImage:flickrInfo]) {
            setOfTags = [setOfTags setByAddingObject:[Tag tagWithTitle:tag inManagedObjectContext:context]];
            photo.sectionAll = tag;
        }
        photo.whereIs = setOfTags;
    } else {
        photo = [photos lastObject];
    }
    
    return photo;
}

+ (void)setAccessDateForPhoto:(Photo *)photo
{
    photo.accessDate = [NSDate date];
}

+ (void)insertThumbnailImageData:(NSData *)thumbnailIageData forPhoto:(Photo *)photo
{
    if (!photo.thumbnailImageData) {
        photo.thumbnailImageData = thumbnailIageData;
    }
}

+ (void)flagPhotoAsDeleted:(Photo *)photo inTag:(Tag *)tag
{
    // remove the empty tag
    if ([tag.photos count] == 1) {
        [photo.managedObjectContext deleteObject:tag];
    }
    
    photo.whereIs = nil;
}

@end
