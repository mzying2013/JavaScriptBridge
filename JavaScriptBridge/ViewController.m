//
//  ViewController.m
//  JavaScriptBridge
//
//  Created by Liu on 2018/9/17.
//  Copyright © 2018年 mzying.com. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>


@implementation NSString(Encode)

-(instancetype)encodeString{
    NSData * data = [self dataUsingEncoding:NSUnicodeStringEncoding];
    return  [[NSString alloc] initWithBytes:data.bytes
                                     length:data.length
                                   encoding:NSUTF8StringEncoding];
}

@end





static NSString * const kConfigurationName1 = @"nameA";
static NSString * const kConfigurationName2 = @"nameB";

@interface ViewController ()<WKScriptMessageHandler,WKNavigationDelegate>

@end

@implementation ViewController
WKWebView * _wkWebView;
UIWebView * _uiWebView;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //WKWebView
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    [configuration.userContentController addScriptMessageHandler:self name:kConfigurationName1];
    [configuration.userContentController addScriptMessageHandler:self name:kConfigurationName2];
//    configuration.preferences.javaScriptEnabled = YES;
//    configuration.processPool = [[WKProcessPool alloc] init];
    
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                    configuration:configuration];
    _wkWebView.navigationDelegate = self;
    [self.view addSubview:_wkWebView];
    
    NSURL * URL = [NSURL URLWithString:@"http://192.168.1.57"];
    NSURLRequest * request = [NSURLRequest requestWithURL:URL];
    [_wkWebView loadRequest:request];
    
    
    
    //UIWebView
    _uiWebView = [UIWebView new];
    [_uiWebView stringByEvaluatingJavaScriptFromString:@""];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:kConfigurationName1]) {
        NSString * body = message.body;
        NSString * name = message.name;
        NSLog(@"%@:%@",name,body);
        
        UIImage * image = [UIImage imageNamed:@"test_cover"];
        NSData * data = UIImagePNGRepresentation(image);
        NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:@"image.jpeg"];
        BOOL result = [data writeToFile:path atomically:YES];
        
        if (result) {
            NSLog(@"写入成功:%@",path);
        }else{
            NSLog(@"写入失败");
        }
        
        NSString * imageSource = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
        NSString * javaScript = [NSString stringWithFormat:@"showImage({'imagePath':'%@','placeholder':'%@'})",imageSource,@"EDCBA"];
        [message.webView evaluateJavaScript:javaScript
                          completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                              NSLog(@"result:%@ error:%@",result,error);
                          }];
    }
    
    if ([message.name isEqualToString:kConfigurationName2]) {
        if (![message.body isKindOfClass:NSDictionary.class]) {
            return;
        }
//        NSDictionary * body = message.body;
//        NSLog(@"%@:%@",message.name,body[@"name"]);
        [message.webView reload];
    }
    
}



#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation:%@",error);
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation:%@",error);
}






@end
