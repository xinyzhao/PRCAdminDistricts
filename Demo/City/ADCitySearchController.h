//
//  ADCitySearchController.h
//  Demo
//
//  Created by xyz on 2019/5/21.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADCitySearchController : UITableViewController
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<NSString *> *searchResults;
@property (nonatomic, copy) void (^didSelectLocation)(NSString *location);

@end

NS_ASSUME_NONNULL_END
