//
//  ADCityViewModel.h
//  Demo
//
//  Created by xyz on 2019/5/22.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADCityViewModel : NSObject
@property (nonatomic, readonly) RACSignal *dataSingle;
@property (nonatomic, readonly) NSInteger selectedProvince;
@property (nonatomic, copy) NSString *selectedCity;
@property (nonatomic, copy) NSArray *hotCities; // default is @[@"北京", @"成都", @"上海", @"深圳", @"广州", @"重庆", @"杭州", @"南京"]

- (void)loadData;

- (NSInteger)numberOfProvinces;
- (NSString *)titleForProvinceInSection:(NSInteger)section;

- (NSInteger)numberOfCitysInSection:(NSInteger)section;
- (NSString *)titleForCityAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isSelectedForCityAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)searchCity:(NSString *)city;

- (void)addRecentCity:(NSString *)city;

@end

NS_ASSUME_NONNULL_END
