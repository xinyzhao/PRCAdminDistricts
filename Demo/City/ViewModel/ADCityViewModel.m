//
//  ADCityViewModel.m
//  Demo
//
//  Created by xyz on 2019/5/22.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ADCityViewModel.h"
#import "PRCAdminDistricts.h"

@interface ADCityViewModel ()
@property (nonatomic, strong) RACSignal *dataSingle;
@property (nonatomic, strong) PRCAdminDistricts *districts;
@property (nonatomic, strong) PRCAdminDistrict *city;
@property (nonatomic, strong) PRCAdminDistrict *recent;
@property (nonatomic, strong) NSDictionary *searchData;

@end

@implementation ADCityViewModel

#define kCityRecentsFile    [NSFileManager documentFile:@"city_recents.plist"]

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSingle = [RACSubject subject];
        self.hotCities = @[@"北京", @"成都", @"上海", @"深圳",
                           @"广州", @"重庆", @"杭州", @"南京"];
    }
    return self;
}

- (void)loadData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        NSString *url = @"https://raw.githubusercontent.com/xinyzhao/PRCAdminDistricts/master/Data/districts_2019_02.txt";
        self.districts = [[PRCAdminDistricts alloc] initWithURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding];
        for (PRCAdminDistrict *province in self.districts.provinces) {
            PRCAdminDistrict *obj = [province.districts firstObject];
            if (obj == nil || obj.code != province.code) {
                obj = [[PRCAdminDistrict alloc] initWithCode:province.code name:province.name];
                obj.parent = province;
                if (province.districts == nil) {
                    province.districts = @[obj];
                } else {
                    province.districts = [@[obj] arrayByAddingObjectsFromArray:province.districts];
                }
            }
        }
        [self loadCustomDistricts];
        [self updateSelectedCity];
        [self updateSerachData];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [(RACSubject *)self.dataSingle sendNext:nil];
        });
    });
}

- (void)loadCustomDistricts {
    NSMutableArray *districts = [[NSMutableArray alloc] init];
    // 最近访问
    self.recent = [[PRCAdminDistrict alloc] initWithCode:-2 name:@"最近访问"];
    [districts addObject:self.recent];
    // 热门城市
    PRCAdminDistrict *hot = [[PRCAdminDistrict alloc] initWithCode:-1 name:@"热门城市"];
    {
        NSMutableArray *citys = [[NSMutableArray alloc] init];
        for (NSString *name in self.hotCities) {
            PRCAdminDistrict *city = [self.districts districtForName:name];
            if (city) {
                [citys addObject:city];
            }
        }
        hot.districts = citys;
    }
    [districts addObject:hot];
    // 全部城市
    PRCAdminDistrict *all = [[PRCAdminDistrict alloc] initWithCode:0 name:@"全部城市"];
    {
        PRCAdminDistrict *obj = [[PRCAdminDistrict alloc] initWithCode:all.code name:all.name];
        obj.parent = all;
        all.districts = @[obj];
        //
        NSMutableDictionary *districts = [self.districts.districts mutableCopy];
        [districts setObject:obj forKey:@(obj.code)];
        [self.districts setValue:[districts copy] forKey:@"districts"];
    }
    [districts addObject:all];
    // 加入自定数据
    [districts addObjectsFromArray:self.districts.provinces];
    [self.districts setValue:[districts copy] forKey:@"provinces"];
    // 加入全部城市后再载入最近访问
    {
        NSArray *names = [NSArray arrayWithContentsOfFile:kCityRecentsFile];
        //
        NSMutableArray *citys = [[NSMutableArray alloc] init];
        for (NSString *name in names) {
            PRCAdminDistrict *city = [self.districts districtForName:name];
            if (city) {
                [citys addObject:city];
            }
        }
        self.recent.districts = citys;
    }
}

- (void)addRecentCity:(NSString *)city {
    PRCAdminDistrict *obj = [self.districts districtForName:city];
    NSMutableArray *districts = [self.recent.districts mutableCopy];
    if ([self.recent.districts containsObject:obj]) {
        [districts removeObject:obj];
    }
    [districts insertObject:obj atIndex:0];
    if (districts.count > 8) {
        [districts removeLastObject];
    }
    self.recent.districts = [districts copy];
    //
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (PRCAdminDistrict *obj in self.recent.districts) {
        [names addObject:obj.name];
    }
    [names writeToFile:kCityRecentsFile atomically:YES];
}

#pragma mark Selection

- (NSInteger)selectedProvince {
    NSInteger index = 0;
    if (self.city.parent) {
        index = [self.districts.provinces indexOfObject:self.city.parent];
    } else if (self.city) {
        index = [self.districts.provinces indexOfObject:self.city];
    }
    if (index < 0 || index >= self.districts.provinces.count) {
        index = 0;
    }
    return index;
}

- (void)setSelectedCity:(NSString *)selectedCity {
    _selectedCity = [selectedCity copy];
    [self updateSelectedCity];
}

- (void)updateSelectedCity {
    if (self.selectedCity == nil) return;
    self.city = [self.districts districtForName:self.selectedCity];
}

#pragma mark View data

- (NSInteger)numberOfProvinces {
    return self.districts.provinces.count;
}

- (NSString *)titleForProvinceInSection:(NSInteger)section {
    PRCAdminDistrict *obj = self.districts.provinces[section];
    return obj.name;
}

- (NSInteger)numberOfCitysInSection:(NSInteger)section {
    PRCAdminDistrict *obj = self.districts.provinces[section];
    return obj.districts.count;
}

- (NSString *)titleForCityAtIndexPath:(NSIndexPath *)indexPath {
    PRCAdminDistrict *obj = self.districts.provinces[indexPath.section];
    PRCAdminDistrict *city = obj.districts[indexPath.row];
    return city.name;
}

- (BOOL)isSelectedForCityAtIndexPath:(NSIndexPath *)indexPath {
    PRCAdminDistrict *obj = self.districts.provinces[indexPath.section];
    PRCAdminDistrict *city = obj.districts[indexPath.row];
    return city.code == self.city.code;
}

#pragma mark Searching

- (void)updateSerachData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (PRCAdminDistrict *province in self.districts.provinces) {
            NSMutableArray *pkeys = [[NSMutableArray alloc] init];
            [pkeys addObject:province.name];
            [pkeys addObject:[province.name stringByPinyinAcronym]];
            [pkeys addObject:[[province.name stringByPinyinStyle:NSStringPinyinStripDiacritics] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            for (PRCAdminDistrict *obj in province.districts) {
                NSMutableArray *ckeys = [[NSMutableArray alloc] init];
                [ckeys addObject:obj.name];
                [ckeys addObject:[obj.name stringByPinyinAcronym]];
                [ckeys addObject:[[obj.name stringByPinyinStyle:NSStringPinyinStripDiacritics] stringByReplacingOccurrencesOfString:@" " withString:@""]];
                //
                [self searchData:dict setName:obj.name forKeys:ckeys];
                if (obj.code != province.code) {
                    [self searchData:dict setName:[NSString stringWithFormat:@"%@，%@", obj.name, province.name] forKeys:pkeys];
                }
            }
        }
        self.searchData = [dict copy];
    });
}

- (void)searchData:(NSMutableDictionary *)dict setName:(NSString *)name forKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        NSMutableArray *array = [dict objectForKey:key];
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
            [dict setObject:array forKey:key];
        }
        if (![array containsObject:name]) {
            [array addObject:name];
        }
    }
}

- (NSArray *)searchCity:(NSString *)city {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *keys = [self.searchData allKeys];
    city = [city lowercaseString];
    for (NSString *key in keys) {
        if ([key hasPrefix:city]) {
            NSArray *array = [self.searchData objectForKey:key];
            [results addObjectsFromArray:array];
        }
    }
    return [results copy];
}

@end
