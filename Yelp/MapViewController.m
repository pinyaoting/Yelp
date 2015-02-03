//
//  MapViewController.m
//  Yelp
//
//  Created by Pythis Ting on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import "Business.h"
#import "Constants.h"

@interface MapViewController () <MKMapViewDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(onListButton)];
    
    // init location
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.774866;
    zoomLocation.longitude= -122.394556;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    self.mapView.delegate = self;
    
    [self plotPositions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plotPositions {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    for (Business *business in self.businesses) {
        [self.mapView addAnnotation:business];
    }
}

#pragma mark - Map view methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Business";
        
    MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"location.png"];//here we use a nice image instead of the default pins
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

#pragma mark - Private methods
- (void)onListButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
