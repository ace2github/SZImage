//
//  UIImage+Compress.h
//  UIImageView-PlayGIF
//
//  Created by ChaohuiChen on 5/26/16.
//  Copyright © 2016 ChaohuiChen All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)
//io
- (UIImage *)compressUseIO:(CGFloat)size;

- (UIImage *)compressUseIO:(CGFloat)size compress:(CGFloat)compress;

+ (UIImage *)compressUseIO:(NSData *)data size:(CGFloat)size compress:(CGFloat)compress;

+ (UIImage *)compressUseIO:(NSData *)data size:(CGFloat)size;


//cg
- (UIImage *)compressUseCGWithSize:(CGSize)size compress:(CGFloat)compress;

- (UIImage *)compressUseCGWithSize:(CGSize)size;
@end
