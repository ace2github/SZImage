//
//  ViewController.m
//  SZImage
//
//  Created by ChaohuiChen on 5/26/16.
//  Copyright © 2016 ChaohuiChen. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Compress.h"
#import "SZGIFImageView.h"

static int timeCount = 0;
static int sizeCount = 0;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    SZGIFImageView *imageView0 = [[SZGIFImageView alloc] initWithFrame:CGRectMake(0, 160, 50, 50)];
    imageView0.gifPath = [[NSBundle mainBundle] pathForResource:@"joy.gif" ofType:nil];
    [self.view addSubview:imageView0];
    
    //[self testImageCompress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testImageCompress {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"small" ofType:@"jpg"]];
    UIImage *srcImage = [UIImage imageWithData:data];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 200, 200)];
    imageView.image = [srcImage compressUseIO:200];;
    [self.view addSubview:imageView];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 280, 200, 200)];
    imageView1.image = [srcImage compressUseCGWithSize:CGSizeMake(200, 187)];
    [self.view addSubview:imageView1];
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"big.png" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        timeCount = sizeCount = 0;
        for (int i=0; i<50; i++) {
            [self bentchmark:@"big.png"];
        }
        NSLog(@"time cg < io count:%d, size cg < io count:%d",timeCount,sizeCount);
        
        
        timeCount = sizeCount = 0;
        for (int i=0; i<256; i++) {
            [self bentchmark:@"small.jpg"];
        }
        NSLog(@"time cg < io count:%d, size cg < io count:%d",timeCount,sizeCount);
    });
}

- (void)bentchmark:(id)name {
    NSLog(@"\r\n ");
    CFTimeInterval time = CACurrentMediaTime();
    
    NSData *data = name;
    if ([name isKindOfClass:[NSString class]]) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
    }
    UIImage *srcImage = [UIImage imageWithData:data];
    
    NSLog(@"ImageIO::");
    CFTimeInterval timeIO = 0;
    CFTimeInterval timeCG = 0.0;

    UIImage *image = [UIImage compressUseIO:data size:200];
    timeIO = CACurrentMediaTime()-time;
    NSLog(@"Time::%f",timeIO);
    NSData *ioData = UIImagePNGRepresentation(image);
    NSLog(@"%f,%f   %lu",image.size.width,image.size.height,ioData.length);
    
    
    
    NSLog(@"UIGraphicsBeginImageContext::");
    time = CACurrentMediaTime();
    image = [srcImage compressUseCGWithSize:CGSizeMake(200, 187)];
    timeCG = CACurrentMediaTime()-time;
    NSLog(@"Time::%f",timeCG);
    NSData *cgData = UIImagePNGRepresentation(image);
    NSLog(@"%f,%f   %lu",image.size.width,image.size.height,cgData.length);
    
    
    NSLog(@"timeCG - timeIO = %f",timeCG - timeIO);
    NSLog(@"CG - IO = %lu",cgData.length - ioData.length);
    
    
    /**
     *  time cg <io:: big=1024 418   small=1024  717
     */
    if (timeCG < timeIO) {
        timeCount ++;
    }
    
    /**
     *  size cg < io:: big=1024 0   small=1024  0
     */
    if (cgData.length < ioData.length) {
        sizeCount ++;
    }
    
}

@end
