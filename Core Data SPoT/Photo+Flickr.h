//
//  Photo+Flickr.h
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/8/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)setAccessDateForPhoto:(Photo *)photo;
+ (void)insertThumbnailImageData:(NSData *)thumbnailIageData forPhoto:(Photo *)photo;
+ (void)flagPhotoAsDeleted:(Photo *)photo;

@end
