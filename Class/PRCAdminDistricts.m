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

@implementation PRCAdminDistricts

- (instancetype)initWithContentsOfFile:(NSString *)file {
    self = [super init];
    if (self) {
        NSError *error = nil;
        NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"[PRCAdminDistricts] load districts error: %@", error);
        } else {
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
                        if (parent == nil) {
                            // 直辖市
                            code -= code % 10000;
                            parent = [districts objectForKey:@(code)];
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
    return self;
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

@end

