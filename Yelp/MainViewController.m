//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FilterViewController.h"
#import "MapViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FilterViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableDictionary *filters;
@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, assign) BOOL shouldPause;

- (void)fetchBusinessesWithQueryIncremental:(BOOL)inc;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        self.searchTerm = @"Restaurants";
        self.filters = nil;
        self.shouldPause = NO;
        self.businesses = [[NSMutableArray alloc] initWithCapacity:20000];
        [self fetchBusinessesWithQueryIncremental:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 63, 320, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searchbar view methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    self.filters = nil;
    [self fetchBusinessesWithQueryIncremental:NO];
}

#pragma mark - Table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - 500;
    if (actualPosition >= contentHeight) {
        if (self.shouldPause) {
            return;
        }
        self.shouldPause = YES;
        [self fetchBusinessesWithQueryIncremental:YES];
    }
}


#pragma mark - Filter delegate methods

-(void)filterViewController:(FilterViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {

    self.filters = [NSMutableDictionary dictionaryWithDictionary:filters];
    [self fetchBusinessesWithQueryIncremental:NO];
    
    // fire a new network event.
    NSLog(@"fire new network event: %@", filters);
}


#pragma mark - Private methods

- (void)onFilterButton {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onMapButton {
    MapViewController *vc = [[MapViewController alloc] init];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}


- (void)fetchBusinessesWithQueryIncremental:(BOOL)inc {
    if (inc) {
        if (!self.offset) {
            self.offset = self.businesses.count;
        } else {
            self.offset += 20;
        }
        if (!self.filters) {
            self.filters = [NSMutableDictionary dictionary];
        }
        [self.filters setObject:@(self.offset) forKey:@"offset"];
    }
    
    
    [self.client searchWithTerm:self.searchTerm params:self.filters success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessesDictionary = response[@"businesses"];
        NSArray *businesses = [Business businessesWithDictionaries:businessesDictionary];
        if (inc) {
            [self.businesses addObjectsFromArray:businesses];
        } else {
            self.businesses = [NSMutableArray arrayWithArray:businesses];
        }
        [self.tableView reloadData];
        self.shouldPause = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

@end
