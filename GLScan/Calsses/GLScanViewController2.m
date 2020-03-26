//
//  GLScanViewController2.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/22.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanViewController2.h"
#import "GLScanQRCode.h"

@interface GLScanViewController2 ()

@property (nonatomic, strong) GLScanQRCode *capture;

@end

@implementation GLScanViewController2

- (void)loadView {
    [super loadView];
    self.capture = [[GLScanQRCode alloc] init];
    self.capture.showView = self.view;
    self.capture.isDoubleTapScale = YES;
    self.capture.isSingleTapAutoFocus = YES;
    [self.capture startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.blackColor;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
