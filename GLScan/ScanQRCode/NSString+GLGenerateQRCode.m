//
//  NSString+GLGenerateQRCode.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/4/2.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "NSString+GLGenerateQRCode.h"
#import <CoreImage/CoreImage.h>

@implementation NSString (GLGenerateQRCode)

- (void)generateQRCodeWithSize:(CGFloat)size callBack:(void (^)(UIImage * _Nonnull))callBackBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self generateQRCodeWithSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBackBlock) {
                callBackBlock(image);
            }
        });
    });
}

- (UIImage *)generateQRCodeWithSize:(CGFloat)size {
    if (self == nil || self.length == 0) {
        NSLog(@"请传入正确的字符串");
        return nil;
    }
    if (size == 0) {
        // 二维码宽高默认值
        size = 80;
    }
    // 创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 过滤器恢复默认
    [filter setDefaults];
    // 给过滤器添加数据，字符串长度最大不得大于893
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    
    // 获取生成的二维码
    CIImage *originImage = [filter outputImage];
    UIImage *image = [self createNoInterPolateFromeCIImage:originImage size:size];
    return image;
}

- (UIImage *)createNoInterPolateFromeCIImage:(CIImage *)originImage size:(CGFloat)size {
    CGRect extent = CGRectIntegral(originImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:originImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
