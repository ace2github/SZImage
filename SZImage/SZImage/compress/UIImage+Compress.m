//
//  UIImage+Compress.m
//  UIImageView-PlayGIF
//
//  Created by ChaohuiChen on 5/26/16.
//  Copyright © 2016 ChaohuiChen All rights reserved.
//

#import "UIImage+Compress.h"
#import <ImageIO/ImageIO.h>
/**
 *  大图压缩时间上io好于cg，小图相反
 *  jpg 压缩大小 io差于cg，cg压缩的更小
 */
@implementation UIImage (Compress)
- (UIImage *)compressUseIO:(CGFloat)size {
    return [self compressUseIO:size compress:1.0];
}

- (UIImage *)compressUseIO:(CGFloat)size compress:(CGFloat)compress{
    NSData *data = UIImageJPEGRepresentation(self, compress);
    return [UIImage compressUseIO:data size:size];
}

+ (UIImage *)compressUseIO:(NSData *)data size:(CGFloat)size compress:(CGFloat)compress {
    UIImage *rImage = [self compressUseIO:data size:size];
    NSData *rData = UIImageJPEGRepresentation(rImage, compress);
    return [UIImage imageWithData:rData];
}

+ (UIImage *)compressUseIO:(NSData *)data size:(CGFloat)size{
    NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent:@(YES),
                              (NSString *)kCGImageSourceThumbnailMaxPixelSize:@(size),
                              (NSString *)kCGImageSourceCreateThumbnailWithTransform:@(YES)
                              };
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    UIImage *rImage = [UIImage imageWithCGImage:imageRef];
    return rImage;
}

- (UIImage *)compressUseCGWithSize:(CGSize)size compress:(CGFloat)compress {
    UIImage *rImage = [self compressUseCGWithSize:size compress:compress];
    NSData *data = UIImageJPEGRepresentation(rImage, compress);
    return [UIImage imageWithData:data];
}

- (UIImage *)compressUseCGWithSize:(CGSize)size{
    CGFloat maxwidth = size.width; CGFloat maxheight = size.height;
    
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, maxwidth, maxheight);
    if (width > maxwidth || height > maxheight) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxwidth;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxheight;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    UIImageOrientation orientation = self.imageOrientation;
    switch(orientation) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, 1.0, self.scale);
    
    //旋转图片的方向
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *rImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rImage;
}
@end
