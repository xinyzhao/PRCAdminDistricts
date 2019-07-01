//
//  ADCityCollectionViewCell.m
//  Demo
//
//  Created by xyz on 2019/5/22.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ADCityCollectionViewCell.h"

@implementation ADCityCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithString:@"f5f5f5"]] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[UIImage imageWithColor:self.tintColor] forState:UIControlStateSelected];
    self.button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

@end
