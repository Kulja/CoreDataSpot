//
//  Photo+Flickr.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "SPoT+Create.h"

@implementation Photo (Flickr)

+ (NSString *)getTitleOfSpotForImage:(NSDictionary *)imageInfo
{
    // getting FLICKR_TAGS out of our image and formating it to our needs
    NSArray *tempArray = [[imageInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
    NSString *tag = @"";
    for (NSString *tempString in tempArray) {
        if (![tempString isEqualToString:@"cs193pspot"] && ![tempString isEqualToString:@"portrait"] && ![tempString isEqualToString:@"landscape"]) {
            tag = [tag stringByAppendingFormat:@"%@ ", tempString];
        }
    }
    // removing space at the end of our formated tag and capitalizing it
    if ([tag length] > 0) {
        tag = [[tag substringToIndex:[tag length] - 1] capitalizedString];
    }
    
    return tag;
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
        NSLog(@"error");
    } else if (![photos count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [[flickrInfo objectForKey:FLICKR_PHOTO_ID] description];
        photo.title = [[flickrInfo objectForKey:FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [[flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.section = [[[flickrInfo objectForKey:FLICKR_PHOTO_TITLE] description] substringToIndex:1];
        photo.squareImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatSquare] absoluteString];
        photo.largeImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.originalImageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatOriginal] absoluteString];
        photo.whereIs = [SPoT spotWithTitle:[Photo getTitleOfSpotForImage:flickrInfo] inManagedObjectContext:context];
        
        [SPoT spotWithTitle:@"All" inManagedObjectContext:context];
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

+ (void)flagPhotoAsDeleted:(Photo *)photo
{
    // remove the empty spot
    if ([photo.whereIs.photos count] == 1) {
        [photo.managedObjectContext deleteObject:photo.whereIs];
    }
    photo.whereIs = nil;
}

@end
