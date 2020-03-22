//
//  GLScanViewController2.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/22.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanViewController2.h"
#import "GLScanCapture.h"

@interface GLScanViewController2 ()

@property (nonatomic, strong) GLScanCapture *capture;

@end

@implementation GLScanViewController2

- (void)loadView {
    [super loadView];
    self.capture = [[GLScanCapture alloc] init];
    self.capture.showView = self.view;
    self.capture.isDoubleTapScale = YES;
    self.capture.isSingleTapAutoFocus = YES;
    [self.capture startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.redColor;
    
    
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
