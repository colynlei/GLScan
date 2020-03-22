//
//  GLScanViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanViewController.h"
#import "GLScanCapture.h"
#import "GLWebViewController.h"

@interface GLScanViewController ()<GLScanCaptureDelegate>

@property (nonatomic, strong) GLScanCapture *capture;

@end

@implementation GLScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.capture = [[GLScanCapture alloc] initWithScanShowView:self.view];
    self.capture.delegate = self;
    self.capture.isDoubleTapScale = YES;
    self.capture.isPinchScale = YES;
    [self.capture startRunning];
}

- (void)gl_capture:(GLScanCapture *)scanCapture resultText:(NSString *)resultText {
    if (resultText) {
        [scanCapture stopRunning];
        GLWebViewController *vc = [[GLWebViewController alloc] init];
        vc.urlString = resultText;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
}

@end
