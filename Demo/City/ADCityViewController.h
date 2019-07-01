//
//  ADCityViewController.h
//  Demo
//
//  Created by xyz on 2019/5/21.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADCityViewController : UIViewController
@property (nonatomic, copy) NSString *selectedCity;
@property (nonatomic, copy) void (^didSelectLocation)(NSString *location);

@end

NS_ASSUME_NONNULL_END
