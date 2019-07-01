//
//  ADCityViewController.m
//  Demo
//
//  Created by xyz on 2019/5/21.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ADCityViewController.h"
#import "ADCitySearchController.h"
#import "ADCityTableViewCell.h"
#import "ADCityCollectionViewCell.h"
#import "ADCityViewModel.h"

@interface ADCityViewController () <UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, weak) IBOutlet UITableView *searchView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *currentButton;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) ZXLocationManager *locationManager;
@property (nonatomic, strong) ADCityViewModel *viewModel;

@property (nonatomic, assign) NSInteger provinceIndex;
@property (nonatomic, strong) NSString *currentCity;

@end

@implementation ADCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"城市列表";
    //
    ADCitySearchController *vc = [[ADCitySearchController alloc] init];
    //
    @weakify(self);
    vc.didSelectLocation = ^(NSString * _Nonnull location) {
        @strongify(self);
        self.searchController.active = NO;
        @weakify(self);
        [[self rac_signalForSelector:@selector(didDismissSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
            @strongify(self);
            [self didSelectLocation:location];
        }];
     };
    //
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:vc];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.barStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
    self.searchController.searchBar.tintColor = self.view.tintColor;
    self.searchController.searchBar.placeholder = @"输入城市名或拼音查询";
    self.definesPresentationContext = YES;
    //
    UITextField *searchField = [self.searchController.searchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor colorWithString:@"f5f5f5"]];
        searchField.layer.cornerRadius = 18;
        searchField.layer.masksToBounds = YES;
        searchField.font = [UIFont systemFontOfSize:12];
    }
    //
    self.searchView.tableHeaderView = self.searchController.searchBar;
    //
    [self.tableView registerNib:[UINib nibWithNibName:@"ADCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ADCityCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"item"];
    //
    self.locationManager = [[ZXLocationManager alloc] init];
    self.locationManager.didUpdateLocation = ^(CLLocation * _Nonnull location, CLPlacemark * _Nonnull placemark) {
        @strongify(self);
        if (placemark) {
            [self.locationManager stopUpdatingLocation];
            self.currentCity = placemark.city;
        }
    };
    [self.locationManager startUpdatingLocation];
    //
    self.viewModel = [[ADCityViewModel alloc] init];
    self.viewModel.selectedCity = self.selectedCity;
    [self.viewModel.dataSingle subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView reloadData];
        self.provinceIndex = [self.viewModel selectedProvince];
    }];
    [self.viewModel loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 自定义导航栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    // 导航栏标题字体
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    // 返回按钮
    UIImage *image = [UIImage imageNamed:@"Return"];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:image style:self.navigationItem.backBarButtonItem.style target:self action:NSSelectorFromString(@"onBack:")]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.searchController.searchResultsController setValue:self.searchController.searchBar forKey:@"searchBar"];
}

- (void)setProvinceIndex:(NSInteger)provinceIndex {
    _provinceIndex = provinceIndex;
    if (self.tableView.indexPathForSelectedRow == nil) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_provinceIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self.collectionView reloadData];
}

- (void)setCurrentCity:(NSString *)currentCity {
    _currentCity = [currentCity copy];
    [self.currentButton setTitle:_currentCity forState:UIControlStateNormal];
}

- (void)didSelectLocation:(NSString *)location {
    if (location) {
        [self.viewModel addRecentCity:location];
        if (_didSelectLocation) {
            _didSelectLocation(location);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Actions

- (IBAction)onCurrentLocation:(id)sender {
    [self didSelectLocation:self.currentCity];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfProvinces];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.viewModel titleForProvinceInSection:indexPath.row];
    return cell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 45 : 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.provinceIndex = indexPath.row;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfCitysInSection:self.provinceIndex];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ADCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:self.provinceIndex];
    [cell.button setTitle:[self.viewModel titleForCityAtIndexPath:indexPath] forState:UIControlStateNormal];
    cell.button.selected = [self.viewModel isSelectedForCityAtIndexPath:indexPath];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:self.provinceIndex];
    self.viewModel.selectedCity = [self.viewModel titleForCityAtIndexPath:indexPath];
    [self didSelectLocation:self.viewModel.selectedCity];
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.bounds.size;
    size.width = (size.width - 10 * 3) / 2;
    size.height = 30;
    return size;
}

#pragma mark <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *city = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *result = [self.viewModel searchCity:city];
    [searchController.searchResultsController setValue:result forKey:@"searchResults"];
}

@end
