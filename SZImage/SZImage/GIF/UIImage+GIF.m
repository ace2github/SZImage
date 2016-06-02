//
//  UIImage+GIF.m
//  SZImage
//
//  Created by ChaohuiChen on 6/1/16.
//  Copyright © 2016 ChaohuiChen. All rights reserved.
//

#import "UIImage+GIF.h"

@implementation UIImage (GIF)
/**
 *  获取每一帧的时间间隔
 *
 *  @param index
 *  @param source source description
 *
 *  @return time duration
 */
+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float duration = 0.1f;
    
    //copy image的属性字典
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)imageProperties;
    
    //获取gif相关属性
    NSDictionary *gifProperties = frameProperties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *unclampedDelayTime = gifProperties[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (unclampedDelayTime) {
        duration = [unclampedDelayTime floatValue];
        
    } else {
        //The amount of time, in hundredths of a second, to wait before displaying the next image in an animated sequence.
        //播放帧与帧的时间间隔
        NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTime) {
            duration = [delayTime floatValue];
        }
    }
    
    //太小会导致太快 参看SDWebImage里面的GIF处理
    if (duration < 0.011f) {
        duration = 0.100f;
    }
    
    //release image properties copy
    CFRelease(imageProperties);

    return duration;
}


/**
 *  gif总的播放时间
 *
 *  @param source
 *
 *  @return
 */
+ (double)totalDuration:(CGImageSourceRef)source {
    NSTimeInterval duration = 0.0f;
    size_t count = CGImageSourceGetCount(source);
    
    if (count > 1) {
        for (size_t i = 0; i < count; i++) {
            //获取每一帧的时间间隔
            duration += [UIImage frameDurationAtIndex:i source:source];
        }
        
        //获取失败，则默认每一帧间隔0.1
        if (duration < 0.011) {
            duration = (1.0f / 10.0f) * count;
        }
    }
    
    return duration;
}


/**
 *  gif 循环时间
 *
 *  @param source
 *
 *  @return 
 */
+ (NSInteger)gifLoopCout:(CGImageSourceRef)source {
    //copy image的属性字典
    CFDictionaryRef imageProperties = CGImageSourceCopyProperties(source, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)imageProperties;
    CFRelease(imageProperties);
    
    //获取gif相关属性
    NSDictionary *gifProperties = frameProperties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *loopCount = gifProperties[(__bridge NSString *)kCGImagePropertyGIFLoopCount];
    if (loopCount) {
        return [loopCount integerValue];
    } else {
        return 1;
    }
}

/**
 *  获取每一帧的图片
 *
 *  @param source
 *
 *  @return
 */
+ (NSArray *)imageFrames:(CGImageSourceRef)source {
    @autoreleasepool {
        NSMutableArray  *frames = [NSMutableArray array];
        NSInteger count = CGImageSourceGetCount(source);
        for (size_t i = 0; i < count; i++) {
            //获取每一帧的图片
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            //获取每一帧的时间间隔
            [frames addObject:[UIImage imageWithCGImage:image]];
            
            //release
            CGImageRelease(image);
        }
        
        return frames;
    }
}

/**
 *  获取GIF的分辨率
 *
 *  @param source source description
 *
 *  @return size
 */
+ (CGSize)dimensionalSize:(CGImageSourceRef)source {
    //默认取第一帧的分辨率做为gif的分辨率
    CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSDictionary *properties = (__bridge NSDictionary *)propertiesRef;
    NSNumber *pixelWidth = properties[(__bridge NSString *)kCGImagePropertyPixelWidth];
    NSNumber *pixelHeight = properties[(__bridge NSString *)kCGImagePropertyPixelHeight];
    CFRelease(propertiesRef);
    
    return CGSizeMake([pixelWidth doubleValue], [pixelHeight doubleValue]);
}


/**
 *   data数据获取动画Image
 *
 *  @param data image data
 *
 *  @return animate image
 */
+ (UIImage *)animatedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    UIImage *animatedImage = nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSArray *images = [UIImage imageFrames:source];
    double duration = [UIImage totalDuration:source];
    if (images && images.count) {
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    
    return animatedImage;
}


/**
 *  mainBundle读取gif图片~~~
 *
 *  @param name gif文件名
 *
 *  @return animate image
 */
+ (UIImage *)imageWithGIFName:(NSString *)name {
    if (!name || !name.length) {
        return nil;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    NSArray *subStrings = [[name lastPathComponent] componentsSeparatedByString:@"."];
    NSString *gifName = subStrings[0];
    
    if (scale == 3.0) {
        gifName = [gifName stringByAppendingString:@"@3x"];
    } else if (scale == 2.0) {
        gifName = [gifName stringByAppendingString:@"@2x"];
    }else {
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        return [UIImage animatedImageWithData:data];
    }else{
        return nil;
    }
}



/**
 *  压缩GIF
 *
 *  @param size
 *
 *  @return return value description
 */
- (UIImage *)compressWithSize:(CGSize)size {
    if ((self.size.width <= size.width && self.size.height <= size.height) ||
        CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }
    
    //计算小压缩比例
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    
    CGSize scaledSize = CGSizeMake(self.size.width * scaleFactor, self.size.height * scaleFactor);
    
    CGPoint point = CGPointZero;
    if (widthFactor > heightFactor) {
        point.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor) {
        point.x = (size.width - scaledSize.width) * 0.5;
    }
    
    @autoreleasepool {
        NSMutableArray *scaledImages = [NSMutableArray array];
        for (UIImage *image in self.images) {
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [image drawInRect:CGRectMake(point.x, point.y, scaledSize.width, scaledSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            [scaledImages addObject:newImage];
            UIGraphicsEndImageContext();
        }
        
        return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
    }
}


@end
