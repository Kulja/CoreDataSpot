//
//  Photo.h
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/21/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * accessDate;
@property (nonatomic, retain) NSString * largeImageURL;
@property (nonatomic, retain) NSString * originalImageURL;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * squareImageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * sectionAll;
@property (nonatomic, retain) NSSet *whereIs;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addWhereIsObject:(Tag *)value;
- (void)removeWhereIsObject:(Tag *)value;
- (void)addWhereIs:(NSSet *)values;
- (void)removeWhereIs:(NSSet *)values;

@end
