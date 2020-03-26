//
//  GLGenerateQRCode.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/23.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLGenerateQRCode.h"
#import <CoreImage/CoreImage.h>

@implementation GLGenerateQRCode

+ (UIImage *)generateQRCodeWithString:(NSString *)string size:(CGFloat)size {
    if (string == nil || string.length == 0) {
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
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    
    // 获取生成的二维码
    CIImage *originImage = [filter outputImage];
    UIImage *image = [GLGenerateQRCode createNoInterPolateFromeCIImage:originImage size:size];
    return image;
}

+ (UIImage *)createNoInterPolateFromeCIImage:(CIImage *)originImage size:(CGFloat)size {
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
