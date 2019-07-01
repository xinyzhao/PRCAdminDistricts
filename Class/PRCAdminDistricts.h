//
// PRCAdminDistricts.h
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
// 中华人民共和国 三级行政区
// 示例数据来源于 中华人民共和国民政部 行政区划代码
// http://www.mca.gov.cn/article/sj/xzqh
// 格式为 行政区划代码 单位名称
// 从第一行行政区划代码110000到最后一行代码，复制到txt文件内并保存
//

#import <Foundation/Foundation.h>

@class PRCAdminDistrict;
static const NSInteger PRCAdminDistrictUnknownCode = NSNotFound;

@interface PRCAdminDistricts : NSObject
@property (nonatomic, readonly) NSDictionary *districts;
@property (nonatomic, readonly) NSArray *provinces; //一级行政区：省

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (instancetype)initWithFile:(NSString *)path encoding:(NSStringEncoding)encoding;
- (instancetype)initWithURL:(NSURL *)url encoding:(NSStringEncoding)encoding;

- (PRCAdminDistrict *)districtForCode:(NSInteger)code;
- (PRCAdminDistrict *)districtForName:(NSString *)name;
@end

@interface PRCAdminDistrict : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) PRCAdminDistrict *parent;
@property (nonatomic, strong) NSArray *districts;

- (instancetype)initWithCode:(NSInteger)code name:(NSString *)name;

- (PRCAdminDistrict *)districtForName:(NSString *)name;
@end

