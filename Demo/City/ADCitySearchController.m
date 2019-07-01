//
//  ADCitySearchController.m
//  Demo
//
//  Created by xyz on 2019/5/21.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ADCitySearchController.h"
#import "ADCitySearchTableViewCell.h"

@interface ADCitySearchController ()

@end

@implementation ADCitySearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ADCitySearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //
    self.tableView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height + self.searchBar.bounds.size.height, 0, self.bottomLayoutGuide.length, 0);
}

- (void)setSearchResults:(NSArray<NSString *> *)searchResults {
    _searchResults = searchResults;
    [self.tableView reloadData];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADCitySearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.searchResults[indexPath.row];
    
    return cell;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *location = self.searchResults[indexPath.row];
    location = [[location componentsSeparatedByString:@"，"] firstObject];
    if (_didSelectLocation) {
        _didSelectLocation(location);
    }
}

@end
