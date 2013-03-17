//
//  ImageCache.m
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/10/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

+ (double)cacheSize
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 10000000;
    } else {
        return 3000000;
    }
}

+ (NSURL *)cacheDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *url = [[paths lastObject] URLByAppendingPathComponent:@"/images/"];
    if (![url checkResourceIsReachableAndReturnError:nil]) {
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return url;
}

+ (NSURL *)imageCacheFilePathFromImageURL:(NSURL *)imageURL
{
    NSURL *url = nil;
    if (imageURL) {
        // getting just the last part of url with extension
        url = [[self cacheDirectory] URLByAppendingPathComponent:[[imageURL pathComponents] lastObject]];
    }
    return url;
}

// image caching
+ (void)saveImageData:(NSData *)imageData forImageURL:(NSURL *)imageURL
{
    NSMutableArray *filesInCache = [[NSMutableArray alloc] init];
    
    dispatch_queue_t imageFetchQ = dispatch_queue_create("image writter", NULL);
    dispatch_async(imageFetchQ, ^{
        [imageData writeToURL:[self imageCacheFilePathFromImageURL:imageURL] atomically:YES];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        double cache_folder_size = 0;
        for (NSURL *url in [fileManager contentsOfDirectoryAtURL:self.cacheDirectory includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLFileSizeKey, NSURLContentAccessDateKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
            cache_folder_size += [[[url resourceValuesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] error:nil] objectForKey:NSURLFileSizeKey] doubleValue];
            
            // adding file urls and dates to an array
            [filesInCache addObject:[NSDictionary dictionaryWithObjectsAndKeys:url, @"url", [[url resourceValuesForKeys:[NSArray arrayWithObject:NSURLContentAccessDateKey] error:nil] objectForKey:NSURLContentAccessDateKey], @"date", nil]];
        }
        
        // sorting file urls by date
        NSSortDescriptor *key = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortedFilesInCache = [filesInCache sortedArrayUsingDescriptors:@[key]];
        
        // deleting lastly accessed file in our sorted file urls
        while (cache_folder_size > [self cacheSize]) {
            cache_folder_size -= [[[[[sortedFilesInCache lastObject] objectForKey:@"url"] resourceValuesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] error:nil] objectForKey:NSURLFileSizeKey] doubleValue];
            [fileManager removeItemAtURL:[[sortedFilesInCache lastObject] objectForKey:@"url"] error:nil];
        }
    });
}

+ (NSData *)imageDataForImageURL:(NSURL *)imageURL
{
    return [NSData dataWithContentsOfURL:[self imageCacheFilePathFromImageURL:imageURL]];
}

@end
