//
//  Business.m
//  Yelp
//
//  Created by Pythis Ting on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        NSArray *address = [dictionary valueForKeyPath:@"location.address"];
        NSArray *neighborhoods = [dictionary valueForKeyPath:@"location.neighborhoods"];
        if (address.count == 0 && neighborhoods.count == 0) {
            NSLog(@"address: %@", address);
            self.address = @"";
        } else {
            NSString *street = @"", *neighborhood = @"";
            if (address.count > 0) {
                street = [dictionary valueForKeyPath:@"location.address"][0];
            }
            if (neighborhoods.count > 0) {
                neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
            }
            if (address.count > 0 && neighborhoods.count > 0) {
                self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
            } else {
                self.address = [NSString stringWithFormat:@"%@", address.count > 0 ? street : neighborhood];
                NSLog(@"address is: %@", self.address);
            }
        }
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    
    return self;
}

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
