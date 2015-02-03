//
//  DetailViewController.h
//  Yelp
//
//  Created by Pythis Ting on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Business.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Business* business;

@end
