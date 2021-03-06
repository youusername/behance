//
//  ViewController.m
//  behance
//
//  Created by zhangjing on 2017/9/25.
//  Copyright © 2017年 214644496@qq.com. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"
#import "Ono.h"


#define WEAKSELF(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define STRONGSELF(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *URLTextField;
@property (weak) IBOutlet NSTextField *infoLabel;
@property (weak) IBOutlet NSView *infoView;
@property (weak) IBOutlet NSView *layerview;


@property (nonatomic,strong) NSMutableArray * listArray;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listArray = [NSMutableArray array];

//    self.URLTextField.stringValue = @"https://www.behance.net/gallery/52499143/Alptraum";
    self.infoView.hidden = YES;
    
    
    NSImageView *view = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 90)];
    view.imageScaling = NSImageScaleNone;
    view.animates = YES;
    view.image = [NSImage imageNamed:@"wait.gif"];
    view.canDrawSubviewsIntoLayer = YES;
    
    
    self.layerview.wantsLayer = YES;
    [self.layerview addSubview:view];
    self.layerview.hidden = YES;
}
- (IBAction)exprot:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg setAllowedFileTypes:@[]];
    [openDlg setMessage:@"选择保存的路径"];
    
    [openDlg beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.layerview.hidden = NO;
                self.infoView.hidden = YES;
                
            });
            NSArray *fileURLs = [openDlg URLs];
            NSURL*fileURL = [fileURLs firstObject];
            NSString *name = [[self.URLTextField.stringValue componentsSeparatedByString:@"/"] lastObject];
            
            
            NSFileManager *manager = [NSFileManager defaultManager];

            NSString* path = [fileURL.absoluteString stringByAppendingPathComponent:name];//拼接

            dispatch_queue_t queue = dispatch_queue_create("wait", DISPATCH_QUEUE_CONCURRENT);
//            @WEAKSELF(self);
            [self.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_async(queue, ^{
                    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj]];
                    NSString * writerStr =[path stringByAppendingPathComponent:[[obj componentsSeparatedByString:@"/"] lastObject]];
                    if (![manager fileExistsAtPath:[NSURL URLWithString:path].absoluteString]) {
                        
                        [manager createDirectoryAtURL:[NSURL URLWithString:path] withIntermediateDirectories:YES attributes:@{} error:nil];
                    }
                    [data writeToURL:[NSURL URLWithString:writerStr] atomically:YES];
                    
                });
            }];

            dispatch_barrier_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.layerview.hidden = YES;
                    self.infoView.hidden = YES;
                    self.URLTextField.stringValue = @"";
                    [[NSWorkspace sharedWorkspace] openFile:path
                                            withApplication:@"Finder"];
                });
            });
        }
    }];

    
}
- (IBAction)beginAction:(id)sender {
    
    if (!self.URLTextField.stringValue) {
        return;
    }
    self.layerview.hidden = NO;
    @WEAKSELF(self);
    [self downloadHtmlURLString:self.URLTextField.stringValue willStartBlock:^{
        
    } success:^(NSData *data) {
        [selfWeak.listArray removeAllObjects];
        [selfWeak.listArray addObjectsFromArray:[selfWeak HTMLDocumentWithData:data]];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            selfWeak.layerview.hidden = YES;
            selfWeak.infoView.hidden = NO;
            selfWeak.infoLabel.stringValue = [NSString stringWithFormat:@"共%ld张",selfWeak.listArray.count];
        });
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        selfWeak.layerview.hidden = YES;
        selfWeak.infoView.hidden = NO;
        selfWeak.infoLabel.stringValue = [NSString stringWithFormat:@"网络错误！"];
        });
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (void)downloadHtmlURLString:(NSString *)urlString willStartBlock:(void(^)(void)) startBlock success:(void(^)(NSData*data)) successHandler failure:(void(^)(NSError *error)) failureHandler{

    if (startBlock) {
        startBlock();
    }
    
    id resp = [[NSUserDefaults standardUserDefaults] objectForKey:urlString];
    if (resp) {
        dispatch_async(dispatch_queue_create("download html queue", nil), ^{
            
            if (successHandler) {
                successHandler(resp);
            }
        });
//        有缓存就直接返回
        return;
    }
    
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"https" ofType:@"cer"];
    NSData * certData =[NSData dataWithContentsOfFile:cerPath];
    NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 是否允许,NO-- 不允许无效的证书
    [securityPolicy setAllowInvalidCertificates:YES];
    // 设置证书
    [securityPolicy setPinnedCertificates:certSet];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // request

    [manager.requestSerializer setValue:@"www.behance.net" forHTTPHeaderField:@"Host"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:55.0) Gecko/20100101 Firefox/55.0" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];

//    [manager.requestSerializer setValue:@"bgk=15634844; bcp=e4f840a5-bdb4-4f34-bc67-28ef150dcdc3; ilo0=true" forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:@"ilo0=true" forHTTPHeaderField:@"Cookie"];
    [manager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"Upgrade-Insecure-Requests"];
    [manager.requestSerializer setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];

    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
    [manager GET:urlString parameters:nil progress:^(NSProgress * progress){
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:task.response.URL.absoluteString];
        
        dispatch_async(dispatch_queue_create("download html queue", nil), ^{
            
            if (successHandler) {
                successHandler(responseObject);
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];

}
- (NSArray*)HTMLDocumentWithData:(NSData*)data{
    NSMutableArray*array = [NSMutableArray new];
    ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
    [doc enumerateElementsWithXPath:@"//div[@id='project-modules']//img//@srcset" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {

        NSArray*earray = [element.stringValue componentsSeparatedByString:@" "];
        [[[earray reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.length>15) {
                NSArray*finallyArray = [obj componentsSeparatedByString:@","];
                [finallyArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull finallyStr, NSUInteger idx, BOOL * _Nonnull finallyStop) {
                    if (finallyStr.length>20) {
                        [array addObject:finallyStr];
                        *finallyStop = YES;
                        *stop        = YES;
                    }
                }];
            }
        }];
        
    }];
    return array;
}
@end
