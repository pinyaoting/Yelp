//
//  MapViewController.m
//  Yelp
//
//  Created by Pythis Ting on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.774866;
    zoomLocation.longitude= -122.394556;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
