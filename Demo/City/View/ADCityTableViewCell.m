//
//  ADCityTableViewCell.m
//  Demo
//
//  Created by xyz on 2019/5/22.
//  Copyright © 2019 xinyzhao. All rights reserved.
//

#import "ADCityTableViewCell.h"

@implementation ADCityTableViewCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.imageView.hidden = !selected;
    self.textLabel.textColor = selected ? self.tintColor : [UIColor colorWithString:@"666666"];
    self.backgroundColor = selected ? [UIColor whiteColor] : [UIColor clearColor];
}

@end
