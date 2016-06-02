//
//  SZGIFImageView.m
//  SZImage
//
//  Created by ChaohuiChen on 6/1/16.
//  Copyright © 2016 ChaohuiChen. All rights reserved.
//

#import "SZGIFImageView.h"
#import "UIImage+GIF.h"

@implementation SZGIFImageView
- (void)setGifPath:(NSString *)path {
    _gifPath = path;
    NSData *data = [[NSData alloc] initWithContentsOfFile:_gifPath];
    UIImage *image = [UIImage animatedImageWithData:data];
    image = [image compressWithSize:self.bounds.size];
    self.animationImages = image.images;
    [self startAnimating];
}
@end
