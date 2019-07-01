//
//  ViewController.m
//  Demo
//
//  Created by xyz on 2019/6/29.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ViewController.h"
#import "ADCityViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *locationButton;

@property (nonatomic, strong) ZXLocationManager *locationManager;
@property (nonatomic, strong) NSString *location;

@end

@implementation ViewController

#define kLocation @"default_location"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    self.location = [[NSUserDefaults standardUserDefaults] stringForKey:kLocation];
    if (self.location == nil) {
        self.location = @"全部城市";
    }
    //
    @weakify(self);
    self.locationManager = [[ZXLocationManager alloc] init];
    self.locationManager.didUpdateLocation = ^(CLLocation * _Nonnull location, CLPlacemark * _Nonnull placemark) {
        @strongify(self);
        [self.locationManager stopUpdatingLocation];
        if (self.location == nil || placemark.city == nil) {
            self.location = placemark.city;
        } else if (![self.location containsString:placemark.city] && ![placemark.city containsString:self.location]) {
            [self tryLocation:placemark.city];
        }
    };
    [self.locationManager startUpdatingLocation];
}

- (void)setLocation:(NSString *)location {
    NSRange range = [location rangeOfString:@"市"];
    if (range.location == location.length - 1 && ![location hasPrefix:@"全部"]) {
        _location = [location substringToIndex:range.location];
    } else {
        _location = [location copy];
    }
    //
    [self.locationButton setTitle:_location forState:UIControlStateNormal];
    //
    [[NSUserDefaults standardUserDefaults] setObject:_location forKey:kLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tryLocation:(NSString *)location {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"检测到您的位置变化，是否改为当前位置？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancel];
    UIAlertAction *change = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.location = location;
    }];
    [alertController addAction:change];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)onLocation:(id)sender {
    ADCityViewController *vc = [[ADCityViewController alloc] init];
    vc.selectedCity = self.location;
    @weakify(self);
    vc.didSelectLocation = ^(NSString * _Nonnull location) {
        @strongify(self);
        self.location = location;
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
