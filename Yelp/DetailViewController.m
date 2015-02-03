//
//  DetailViewController.m
//  Yelp
//
//  Created by Pythis Ting on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface DetailViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadAsyncLabels];
    
    // init location
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.business.coordinate.latitude;
    zoomLocation.longitude= self.business.coordinate.longitude;
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
    [self.mapView addAnnotation:self.business];

}

- (void)loadAsyncLabels {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.business.ratingImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    [self.ratingImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.ratingImageView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ self.ratingImageView.image = image;
        } completion:nil];
    } failure:nil];
}

- (void)setBusiness:(Business *)business {
    _business = business;
    
    self.nameLabel.text = self.business.name;
    self.reviewLabel.text = [NSString stringWithFormat:@"%ld Reviews", self.business.numReviews];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.business.distance];
    self.categoryLabel.text = self.business.categories;

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Business";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"location.png"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Business *business = (Business*)view.annotation;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [business.mapItem openInMapsWithLaunchOptions:launchOptions];
}

@end
