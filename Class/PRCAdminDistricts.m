//
// PRCAdminDistricts.m
//
// Copyright (c) 2019 Zhao Xin (https://github.com/xinyzhao)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "PRCAdminDistricts.h"

@interface PRCAdminDistricts ()
@property (nonatomic, strong) NSDictionary *districts;
@property (nonatomic, strong) NSArray *provinces;

@end

@implementation PRCAdminDistricts

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        [self parseData:string];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    NSString *str = [[NSString alloc] initWithData:data encoding:encoding];
    return [self initWithString:str];
}

- (instancetype)initWithFile:(NSString *)path encoding:(NSStringEncoding)encoding {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data encoding:encoding];
}

- (instancetype)initWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding {
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [self initWithData:data encoding:encoding];
}

- (void)parseData:(NSString *)data {
    if (data) {
        NSMutableDictionary *districts = [[NSMutableDictionary alloc] init];
        NSMutableArray *provinces = [[NSMutableArray alloc] init];
        NSArray *lines = [data componentsSeparatedByString:@"\n"];
        NSInteger code;
        NSString *name;
        for (NSString *line in lines) {
            NSArray *pair = [line componentsSeparatedByString:@"\t"];
            code = pair.count > 0 ? [pair[0] integerValue] : 0;
            name = pair.count > 1 ? pair[1] : nil;
            if (code > 0 && name.length > 0) {
                PRCAdminDistrict *obj = [[PRCAdminDistrict alloc] initWithCode:code name:name];
                [districts setObject:obj forKey:@(code)];
                // 一级行政区：省
                if (code % 10000 == 0) {
                    [provinces addObject:obj];
                } else if (code % 100 == 0) {
                    //二级行政区：市、区(直辖市)
                    code -= code % 10000;
                    PRCAdminDistrict *parent = [districts objectForKey:@(code)];
                    if (parent.districts == nil) {
                        parent.districts = @[obj];
                    } else {
                        parent.districts = [parent.districts arrayByAddingObject:obj];
                    }
                    obj.parent = parent;
                } else {
                    // 三级行政区：区、县等待
                    code -= code % 100;
                    PRCAdminDistrict *parent = [districts objectForKey:@(code)];
                    // 直辖市
                    if (parent == nil) {
                        code -= code % 10000;
                        PRCAdminDistrict *node = [districts objectForKey:@(code)];
                        // 补充二级数据
                        if (node.districts == nil) {
                            parent = [[PRCAdminDistrict alloc] initWithCode:node.code name:node.name];
                            parent.parent = node;
                            node.districts = @[parent];
                        } else {
                            parent = [node.districts firstObject];
                        }
                    }
                    if (parent.districts == nil) {
                        parent.districts = @[obj];
                    } else {
                        parent.districts = [parent.districts arrayByAddingObject:obj];
                    }
                    obj.parent = parent;
                }
            }
        }
        //
        self.districts = [districts copy];
        self.provinces = [provinces copy];
    }
}

- (PRCAdminDistrict *)districtForCode:(NSInteger)code {
    return [self.districts objectForKey:@(code)];
}

- (PRCAdminDistrict *)districtForName:(NSString *)name {
    for (PRCAdminDistrict *obj in self.provinces) {
        if ([obj.name hasPrefix:name]) {
            return obj;
        }
    }
    for (PRCAdminDistrict *obj in self.provinces) {
        for (PRCAdminDistrict *city in obj.districts) {
            if ([city.name hasPrefix:name]) {
                return city;
            }
        }
    }
    for (PRCAdminDistrict *obj in self.provinces) {
        for (PRCAdminDistrict *city in obj.districts) {
            for (PRCAdminDistrict *district in city.districts) {
                if ([district.name hasPrefix:name]) {
                    return district;
                }
            }
        }
    }
    return [[PRCAdminDistrict alloc] initWithCode:PRCAdminDistrictUnknownCode name:name];;
}

@end

@implementation PRCAdminDistrict

- (instancetype)initWithCode:(NSInteger)code name:(NSString *)name {
    self = [super init];
    if (self) {
        self.code = code;
        self.name = name;
    }
    return self;
}

- (PRCAdminDistrict *)districtForName:(NSString *)name {
    for (PRCAdminDistrict *obj in self.districts) {
        for (PRCAdminDistrict *sub in obj.districts) {
            if ([sub.name hasPrefix:name]) {
                return sub;
            }
        }
    }
    for (PRCAdminDistrict *obj in self.districts) {
        PRCAdminDistrict *sub = [obj districtForName:name];
        if (sub) {
            return sub;
        }
    }
    return [[PRCAdminDistrict alloc] initWithCode:PRCAdminDistrictUnknownCode name:name];
}

@end

