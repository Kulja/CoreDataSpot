//
//  ImageViewController.h
//  Core Data SPoT
//
//  Created by Marko Kuljanski on 3/10/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// the Model for this VC
// simply the URL of a UIImage-compatible image (jpg, png, etc.)
@property (nonatomic, strong) NSURL *imageURL;

@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

@end
