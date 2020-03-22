//
//  GLWebViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/23.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLWebViewController.h"
#import <WebKit/WebKit.h>

@interface GLWebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation GLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
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
