//
//  UIImage+GIF.h
//  SZImage
//
//  Created by ChaohuiChen on 6/1/16.
//  Copyright © 2016 ChaohuiChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

@interface UIImage (GIF)
/**
 *  获取每一帧的时间间隔
 *
 *  @param index
 *  @param source source description
 *
 *  @return time duration
 */
+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source ;

/**
 *  gif总的播放时间
 *
 *  @param source
 *
 *  @return
 */
+ (double)totalDuration:(CGImageSourceRef)source ;


/**
 *  gif 循环时间
 *
 *  @param source
 *
 *  @return
 */
+ (NSInteger)gifLoopCout:(CGImageSourceRef)source ;


/**
 *  获取每一帧的图片
 *
 *  @param source
 *
 *  @return
 */
+ (NSArray *)imageFrames:(CGImageSourceRef)source ;


/**
 *  获取GIF的分辨率
 *
 *  @param source source description
 *
 *  @return size
 */
+ (CGSize)dimensionalSize:(CGImageSourceRef)source ;

/**
 *   data数据获取动画Image
 *
 *  @param data image data
 *
 *  @return animate image
 */
+ (UIImage *)animatedImageWithData:(NSData *)data ;


/**
 *  mainBundle读取gif图片~~~
 *
 *  @param name gif文件名
 *
 *  @return animate image
 */
+ (UIImage *)imageWithGIFName:(NSString *)name ;



/**
 *  压缩GIF
 *
 *  @param size
 *
 *  @return return value description
 */
- (UIImage *)compressWithSize:(CGSize)size ;
@end
