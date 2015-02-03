//
//  FilterViewController.m
//  Yelp
//
//  Created by Pythis Ting on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "SwitchCell.h"
#import "PickerCell.h"
#import "SeeAllCell.h"
#import "Constants.h"

@interface FilterViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSDictionary *filters;

@property (nonatomic, strong) NSDictionary *pickers;

@property (nonatomic, strong) NSMutableDictionary *constraints;
@property (nonatomic, strong) NSArray *constraintsSectionTitles;
@property (nonatomic, strong) NSMutableDictionary *selectedConstraints;

@property (nonatomic, strong) NSArray *options;

- (void)initFilters;

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedConstraints = [NSMutableDictionary dictionary];
        [self initFilters];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PickerCell" bundle:nil] forCellReuseIdentifier:@"PickerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SeeAllCell" bundle:nil] forCellReuseIdentifier:@"SeeAllCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *options = [self getOptionsAtSection:section];
    NSString *type = [self getTypeAtSection:section];
    
    if ([type isEqualToString:@"picker"]) {
        BOOL expand = [self getToggleAtSection:section];
        if (!expand) {
            return 1;
        }
    } else if ([type isEqualToString:@"switch_group"]) {
        BOOL expand = [self getToggleAtSection:section];
        if (!expand) {
            return 6;
        }
    }
    return options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [self getTypeAtSection:indexPath.section];
    
    if ([type hasPrefix:@"switch"]) {
        BOOL expand = [self getToggleAtSection:indexPath.section];
        if ([type isEqualToString:@"switch_group"] && !expand && indexPath.row == 5) {
            SeeAllCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SeeAllCell"];
            return cell;
        }
        NSDictionary *constraint = [self getOptionAtIndexPath:indexPath];
        NSString *sectionTitle = [self.constraintsSectionTitles objectAtIndex:indexPath.section];
        SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

        cell.titleLabel.text = constraint[@"name"];
        cell.on = [(NSMutableSet*)[self.selectedConstraints objectForKey:sectionTitle] containsObject:constraint];
        cell.delegate = self;
        return cell;
    } else {
        BOOL expand = [self getToggleAtSection:indexPath.section];

        NSInteger selected = [self getSelectedAtSection:indexPath.section];
        PickerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!expand) {
            cell.optionLabel.text = [self getOptionAtIndexPath:indexPath withIndex:selected][@"name"];
            cell.moreLabel.hidden = NO;
        } else {
            cell.optionLabel.text = [self getOptionAtIndexPath:indexPath withIndex:indexPath.row][@"name"];
            cell.moreLabel.hidden = YES;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [self getTypeAtSection:indexPath.section];
    
    if ([type isEqualToString:@"picker"]) {
        [self toggleExpandAtSection:indexPath.section];
        [self setSelected:indexPath.row AtSection:indexPath.section];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex:indexPath.section]  withRowAnimation:UITableViewRowAnimationFade];
    } else if ([type isEqualToString:@"switch_group"]) {
        [self toggleExpandAtSection:indexPath.section];
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex:indexPath.section]  withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.constraintsSectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.constraintsSectionTitles objectAtIndex:section];
}

#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *sectionTitle = [self.constraintsSectionTitles objectAtIndex:indexPath.section];
    NSDictionary *constraint = [self getOptionAtIndexPath:indexPath];
    NSMutableSet *constraintSet = self.selectedConstraints[sectionTitle];
    if (value) {
        if (constraintSet) {
            [constraintSet addObject:constraint];
        } else {
            self.selectedConstraints[sectionTitle] = [NSMutableSet setWithObject:constraint];
        }
    } else {
        [self.selectedConstraints[sectionTitle] removeObject:constraint];
    }
}

#pragma mark - Private methods

- (NSMutableDictionary *)getConstraintsAtSection:(NSInteger)section {
    NSString *sectionTitle = [self.constraintsSectionTitles objectAtIndex:section];
    return [self.constraints objectForKey:sectionTitle];
}

- (NSDictionary *)getOptionAtIndexPath:(NSIndexPath *)indexPath withIndex:(NSInteger)index {
    NSDictionary *constraints = [self getConstraintsAtSection:indexPath.section];
    NSArray *options = [constraints objectForKey:@"options"];
    return options[index];
}

- (NSDictionary *)getOptionAtIndexPath:(NSIndexPath *)indexPath {
    return [self getOptionAtIndexPath:indexPath withIndex:indexPath.row];
}

- (NSArray *)getOptionsAtSection:(NSInteger)section {
    NSDictionary *constraints = [self getConstraintsAtSection:section];
    return [constraints objectForKey:@"options"];
}

- (NSString *)getTypeAtSection:(NSInteger)section {
    NSDictionary *constraints = [self getConstraintsAtSection:section];
    return [constraints objectForKey:@"type"];
}

- (NSInteger)getSelectedAtSection:(NSInteger)section {
    NSDictionary *constraints = [self getConstraintsAtSection:section];
    return [[constraints objectForKey:@"selected"] integerValue];
}

- (NSString *)getRulenameAtSection:(NSInteger)section {
    NSDictionary *constraints = [self getConstraintsAtSection:section];
    return [constraints objectForKey:@"rulename"];
}

- (void)setSelected:(NSInteger)index AtSection:(NSInteger)section {
    NSMutableDictionary *constraints = [self getConstraintsAtSection:section];
    [constraints setObject:@(index) forKey:@"selected"];
}

- (BOOL)getToggleAtSection:(NSInteger)section {
    NSDictionary *constraints = [self getConstraintsAtSection:section];
    
    return [[constraints objectForKey:@"expand"] boolValue];
}

- (void)toggleExpandAtSection:(NSInteger)section {
    NSMutableDictionary *constraints = [self getConstraintsAtSection:section];
    BOOL toggle = [[constraints objectForKey:@"expand"] boolValue];
    
    [constraints setObject:@(!toggle) forKey:@"expand"];
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    NSInteger i, selected;
    NSString *type, *rulename, *sectionTitle;
    NSArray *options;
    NSDictionary *targetOption;
    
    for (i = 0; i < self.constraintsSectionTitles.count; i++) {
        rulename = [self getRulenameAtSection: i];
        type = [self getTypeAtSection:i];
        if ([type hasPrefix:@"switch"]) {
            sectionTitle = self.constraintsSectionTitles[i];
            if (self.selectedConstraints.count > 0 && self.selectedConstraints[sectionTitle]) {
                NSMutableArray *names = [NSMutableArray array];
                for (NSDictionary *category in self.selectedConstraints[sectionTitle]) {
                    [names addObject:category[@"code"]];
                }
                NSString *categoryFilter = [names componentsJoinedByString:@","];
                [filters setObject:categoryFilter forKey:rulename];
            }
            continue;
        }
        selected = [self getSelectedAtSection: i];
        options = [self getOptionsAtSection: i];
        targetOption = options[selected];
        [filters setObject:targetOption[@"code"] forKey:rulename];
    }
    
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearchButton {
    [self.delegate filterViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void)initFilters {
    self.constraintsSectionTitles = @[@"Sort", @"Distance", @"Deals", @"Categories"];
    
    NSDictionary* filters =
    @{
      @"Sort": @{
              @"type": @"picker",
              @"rulename": @"sort",
              @"options": @[
                      @{@"name": @"Best Match", @"code": @0},
                      @{@"name": @"Distance", @"code": @1},
                      @{@"name": @"Higest Rated", @"code": @2}
                      ],
              @"selected": @0,
              @"expand": @NO
              },
      @"Distance": @{
              @"type": @"picker",
              @"rulename": @"radius_filter",
              @"options": @[
                      @{@"name": @"Best Match", @"code": @0},
                      @{@"name": @"0.3 miles", @"code": @483},
                      @{@"name": @"1 mile", @"code": @1609},
                      @{@"name": @"5 miles", @"code": @8047},
                      @{@"name": @"20 mile", @"code": @32187},
                      ],
              @"selected": @0,
              @"expand": @NO
              },
      @"Deals": @{
              @"type": @"switch",
              @"rulename": @"deals_filter",
              @"options": @[
                      @{@"name": @"Only business with deals", @"code": @"1"}
                      ]
              },
      @"Categories": @{
              @"type": @"switch_group",
              @"rulename": @"category_filter",
              @"options": @[
                      @{@"name" : @"Barbeque", @"code": @"bbq" },
                      @{@"name": @"Cafes", @"code": @"cafes"},
                      @{@"name" : @"French", @"code": @"french" },
                      @{@"name": @"Hot Pot", @"code": @"hotpot"},
                      @{@"name" : @"Italian", @"code": @"italian" },
                      @{@"name": @"Japanese", @"code": @"japanese"},
                      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                      @{@"name" : @"Mexican", @"code": @"mexican" },
                      @{@"name" : @"Pizza", @"code": @"pizza" },
                      @{@"name": @"Seafood", @"code": @"seafood"},
                      @{@"name" : @"Soup", @"code": @"soup" },
                      @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                      @{@"name": @"Thai", @"code": @"thai"},
                      @{@"name": @"Vegetarian", @"code": @"vegetarian"}
                      ]
              },
              @"expand": @NO
      };
    
    self.constraints = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)(filters), kCFPropertyListMutableContainers));
    
}

@end
