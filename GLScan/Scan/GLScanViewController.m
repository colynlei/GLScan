//
//  GLScanViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanViewController.h"
#import "GLScanCapture.h"

@interface GLScanViewController ()

@property (nonatomic, strong) GLScanCapture *capture;

@end

@implementation GLScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.capture = [[GLScanCapture alloc] initWithScanShowView:self.view];
    [self.capture startRunning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
}

@end
