//
//  ICResultViewController.m
//  demoApp
//
//  Created by tourituyou on 2019/7/9.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "ICResultViewController.h"
#import "UITool.h"
#import "faceIDManager.h"
#import "hudView.h"
#import "fouthViewController.h"

@interface ICResultViewController ()<UIWebViewDelegate, faceIDManagerDelegate>
@property (nonatomic, strong) UIButton *nextBT;
@property (nonatomic, strong) hudView *myHud;
@property (nonatomic, strong) UIButton *readButton;
@end

@implementation ICResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    [array removeObjectAtIndex:(array.count - 2)];
    [self.navigationController setViewControllers:[array copy] animated:YES];
    
    self.title = @"読み取り結果の確認";
    [self initView];
    [self initProgressBar];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.6 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)initView {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, [UIScreen mainScreen].bounds.size.width - 32, 120)];
    sectionL.numberOfLines = 0;
    sectionL.textAlignment = NSTextAlignmentLeft;
    sectionL.text = [NSString stringWithFormat:@"ICチップから情報を読み取りました。\n読み取り結果が正しいことを確認してください。"];
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = kBodyTextColor;
    [self.view addSubview:sectionL];
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = kBaseColorUnEnabled;
    footBT.userInteractionEnabled = false;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
    self.nextBT = footBT;
    
    UILabel *frontTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 170, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    frontTitle.textAlignment = NSTextAlignmentCenter;
    frontTitle.text = [NSString stringWithFormat:@"読み取り結果"];
    frontTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [self.view addSubview:frontTitle];
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(40, 215, [UIScreen mainScreen].bounds.size.width - 80, 1)];
    web.delegate = self;
    web.backgroundColor = [UIColor whiteColor];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.currentModel.kbnModel.STM4 ofType:@"html"];
    NSURL *locationURL = [NSURL URLWithString:filePath];
    NSURLRequest *request =[NSURLRequest requestWithURL:locationURL];
    [web setScalesPageToFit:YES];
    web.userInteractionEnabled = NO;
    [web loadRequest:request];
    [self.view addSubview:web];
    
//    UIButton *BT2 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [BT2 setFrame:CGRectMake(40, 425, [UIScreen mainScreen].bounds.size.width - 80, 50)];
//    [BT2 setTitle:@"やり直し" forState:UIControlStateNormal];
//    [BT2 addTarget:self action:@selector(didBT2Click) forControlEvents:UIControlEventTouchUpInside];
//
//    [BT2 setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] forState:UIControlStateNormal];
//    BT2.layer.borderWidth = 2.0f;
//    BT2.layer.cornerRadius = 3.0f;
//    BT2.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
//    BT2.layer.masksToBounds = YES;
//
//    [self.view addSubview:BT2];
//    self.readButton = BT2;
    
    UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
    [check setFrame:CGRectMake(40, 425, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [check addTarget:self action:@selector(didChecked:) forControlEvents:UIControlEventTouchUpInside];
    [check setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
    [check setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
    [check setTitleColor:kBodyTextColor forState:UIControlStateNormal];
    [check setTitle:@"確認しました。" forState:UIControlStateNormal];
    check.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:check];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat h = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    CGFloat w = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"] floatValue];
    
    float rate = h / w;
    float w1 = [UIScreen mainScreen].bounds.size.width - 80;
    float h1 = rate * w1;
    webView.frame = CGRectMake(40, 215, w1, h1);

    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:[self getParamDic]];
    NSString *str = [NSString stringWithFormat:@"%@", [self convertToJsonData:dic]];
    NSString *jsStr = [NSString stringWithFormat:@"render('%@')", str];
    [webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)didChecked:(UIButton *)button{
    button.selected = !button.isSelected;
    
    self.readButton.backgroundColor = button.isSelected ? kBaseColorUnEnabled : [UIColor whiteColor];
    self.readButton.layer.borderColor = button.isSelected ? [UIColor clearColor].CGColor : kBaseColor.CGColor;
    self.readButton.userInteractionEnabled = !button.isSelected;
    button.isSelected ? [self.readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] : [self.readButton setTitleColor:kBaseColor forState:UIControlStateNormal];
    
    self.nextBT.backgroundColor = button.selected ? kBaseColor : kBaseColorUnEnabled;
    self.nextBT.userInteractionEnabled = button.selected;
}

- (void)didBT2Click{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - faceID相关
- (void)goNextView {
    hudView *hud = [[hudView alloc] initWithModel:nil andController:nil];
    [hud show];
    self.myHud = hud;
    faceIDManager *manager = [faceIDManager sharedFaceIDManager];
    manager.delegate = self;
    [manager getBizTokenWithImage:[UIImage imageNamed:@"face"] viewController:self];
}

- (void)getBizTokenSuccuss:(NSString *)bizToken{
    fouthViewController *f = [[fouthViewController alloc] init];
    [self.myHud hide];
    [self.navigationController pushViewController:f animated:YES];
}

- (void)didVerifyFailure:(NSString *)msg title:(NSString *)title{
    [self.myHud hide];
    [self showAlert:msg title:title];
}

- (void)showAlert:(NSString *)msg title:(NSString *)title{
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [a dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}

- (NSDictionary *)getParamDic{
    if ([self.currentModel.kbnModel.name isEqualToString:@"運転免許証"]) {
        return @{@"dl-name" : @"東京太郎",
                 @"dl-birth" : @"昭和５１年9月１７日",
                 @"dl-addr" : @"東京都町田市鶴見",
                 @"dl-issue" : @"平成27年09月02日",   // 交付時間
                 @"dl-ref" : @"00005",     // 交付番号
                 @"dl-expire" : @"平成３０年10月17日",  // 有効期限
                 @"dl-is-expired" : @"０００",   //
                 @"dl-number" : @"300845678990",  // 番号
                 @"dl-sc" : @"PFU",      // 公安委員会
                 @"dl-condition1" : @"眼鏡等",   // 免許条件１
                 @"dl-condition2" : @"中型車は中型車（８t）に限る",   // 免許条件２
                 //                          @"dl-condition3" : @"５５５",   // 免許条件３
                 //                          @"dl-condition4" : @"６６６",   // 免許条件４
                 @"dl-photo" : @"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMAAAADwCAMAAABheJuYAAAAwFBMVEUFBQELCA0nBAIWCgsMDRYMEB0dDhAgGCESHCQnGhsuISS1ACwSMEQ6NDgGUHK7IUVTR0RNSVAEcZ+FWjC+RHCBX2x6ZGFnaW8Amdt+gYfpYpwNoucAp+msfopEm8TcfX7efKSPl5+7lXmWnqaFprjCmKSgp6+Eq9pBvutntt/mnltvt9n0n1devfHUpLCLt89owe/jpLSttbxqyPP1spPqsb69wsf4wZuj2/X5zKHR1tnO6/r34eXi5+nw9PX9//wEgx4iAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB+IIAwoWBk3xYTIAACAASURBVHjavV2Nbtu6kqblVI60lWu7qYIaWMUQbuGjprxhSzeCgWLP+7/VkhTJmSEpWU6TCGjiOrI8Hznk/HKGCdF1gpuf6lfXdZyb1+rf46P+2amfgnfd45N+KfRdQqpf6rWUopPmLfUZ8fj0aP6qPqJu7qT+6+Oj7PTT1LPUm4/mFvW7M49Xt+i3OX/U39U92q9U76uHq0dK80n9QGE+pT/Hh2eq14ZowRnXt3JDlP7NxUBQfInhRv1K0yYl59JeBpTQ78nhAfZt+zduoOqPDQ83L93f9PP4cO9wn3+mGH6azwv7/VLY7x8eqP7ABood1eil+y/cYP+mKbUP9t81XMNjzQR5BO4vw9v2s/Z96b7FgzWv7IcFfrRAzzE/h1HjnHkSLfV+XDhGIez3CzfYdjz8E/0AcvcFaBzdK/c/TwlHCOwXOBT+HU7HkA/fa/6oXzP8B0es5RU8J3QuJPxX+hEfmIQPMwOjPAwXDLFwQywtSwjyWPscCWPBhyGj3y7dIDL7DMviHosA9gkYyU+UewErQfgBM2NoKQAkhNngv47NBMwN/FXaRSPoYPqLcTeRQvgh98zjZgtNoAjmRSIMmBPtGuHAGp6zBVnUXEjEjRIzpZ9ITsdRIl5hIqTIDyPnbkGKcBmE68IN+bAG7exyNKRk7dIViSaTTqnAw+6JwV9qWUhKnpgeHr7pd7MQagAGlifdfGTqczIaEry1SU8F9xsgfoBbxBLmgPyMx5nQK6WQKa6U0o0YCAPpZigxBm7b8CsVARAc35/6KBNSYJw83vhFjAMtRVhwdMfisNsMEBADccJN3HOIkO7rZXJo/E6J1j8CIAVHO7NjA0mGdljrEgNwpJCbLe93TdM19/dV0+g3OuFXLlpZ6GNm1+DkLTxuw7ZiNQGHk5HtjKP9h8hkEaz+4TuQeEK7jwbVrBt9VWW13RZltt1ud1+brwqNkLBrWmaDlevGN8UuPJh6xEISYHIRYsCKELrLQ5Yhd3VSEb7OV+uPi2VeFKW9CvVyvS0z9cdObxqSyrqU4uB4heM5AAXGjh/zm1fIxH7PRyLab8oBl1rBqTTLplov/ZV7+jWEUsPJsm25bXhH5BrwgEwAIKoaR2qWeYIFYCU7huB0PwIAHguzb95oml3TVbfraomu3NNeljAZZbFdf1zvOiyDYwBcUPENIpQoV5J52SDxbg8aLGhEXnUJ9E/1rmKaarn4uAwuPQMFngWLJsuXS7YeLBDgSKK5gnYhEc8i3cQtU2ZvIAJXBBoF5vtQ5nVqp9lty2KZuDwLERBqOZi/7tRySOzSnEoUiTXgYAFr4ljMfCBxnQVjzZUBNdqTlM3UKNqrIivKPA2gMMyPERTuXsZub3eK8wQWCaEOT6wQtOSdhuHUaRndz+Mt1aqpbk6kMvm22yobuCQFoPBDXhToNZ6uvGrUHCYAhHuSI5uucwUAK+2BJsRBORWSvGt4p9ndbzM/sMkZwAAKAEAQrNcfb3ddaEiB5kN2QAFWDqwBSeFKAQo2UlSGfcri0UL2vsK8XVwGUMDr6Obbe6dUcrs8vWjkQsZKvd9T7QyEawkzYbTHmT92u4quzBQAtGwvAFgu14M4D7hfYhsMDA204TOZVp24QBKO6J/q4123y4LNcXQNANlOIJdFcsvSfMSNFYFNBWmUI2wtgOrJxwFwrKFIZHkZ5ucx+WW5HGEhxPuFl2kptOr2rRYN9ht5bGtwrCK43YQJGVsZ1HAFT8ew1HfrykgoKp6W47sQlsflFICque+Qve7lVui+ccLVGDROT+MJF5AIZkD/6tZVVkTidXIbBQCOkUYAlEW240SLEd6MltKpAXTLZMgK5l6ABSaL40b9QcM+CQSXAVyYLn27+kAjrV9GCmSVSrCDJHEiSEY8QWh/cugF1nhFc19msJ1f2oVyOvhWpytGWcjcuV43xk9hmd0bL4EN5YaWxaKLE6cVGgPFPtssQwIVlINyTJXwN/jFrD+WBmC23SLLqiaysZ03M/BcOL9Q4A/l0SqwN69BQS7IHBTpGfBc7wHYn8txAEbdvu+oZiAT82BdBCxyiPqN17o4vDtQfLxZYgvrMg/liHMs6cMcpOnPCwewbJDN7OjnsU0pBdJGifpgJQUx87qPyMQClnb/z9MsBACQOjcBwHwkM8aCxK4mzrEl6P1MAwDpXDlcUB8nBtA1DNuI9quKqZ3F8X7hmX8SANpns7Jay0C9pA4PiXyj1hfsvXfIxY8NlwqpZ2VkahVjizjYSw2gfBSAe7YyGsBQkMj/yQPtn3FYJFiDk9gvqN5vdh8Jm0Zbez66rcy9eVmUblaHjapBHjohiAYEzjGGVjVaAtjnqq8mxzt7MVM45XTgQSaMyIEC9lv9uMrtRRJ0oMikZVJSJ75IuKKVAIgdJcFMpOUAscMAQ54vR2+3q95YzZ2MloF3DUqvTnOyLxEHrzPtmyoe05ArpnSJYNMdY6ECEBgA+Q6Z6CMhDoZ82tTyRbibVcpVdXkGiNy7eDMGYCF+7IAcbCsDq3PkmfOhM6yL6w91axbbKOHOMqpKYIPSL4KxJeBus09brJsOKcvgbIS1yhDby5R3Ro3/dhUYWVgtuCCJS7+tFJfU0RwB9Q/bNs6ZI+jIh9toaNJwdx/nOxZ6ekowD4GuKaO4LGZto0hce0NzvQZFn6M91EkEFlhtdpqQQ7KjAIqAifw8XNKnywIU0wkA7vLvat2U+6gvcdUaAD5ShAJAEoIWsmvWqe9Aev4FQVAU8/ZctI0SZSMvGo4Dp3gajGOLAiAKk9GA1gk+tfs62ZKKC/o0mYyJGTCfwG9vm4FukYylMhJvjj0pTWKQimhjGWUL75ALTONxQRxP0c3HLnILEpvYq/ySRGCHhdKMuGsjBGNroEiwUBptPqbbssq7VbBnGRxbOIROXSyyuRnRLz0fldWEiplHsYEJtwSJ5+SUibp07FqYIB+N9hAPZPcxLZq8SblabdrNqkDCcwrA5IJfEmcTeVh534X7v3etsMAvLbHpzD+OOcyHOchvqro/t5uBS8YlmR/8lWOTPG3+xHJg+EvVhUkSWBuFoDiE6AeXTLNI+J7ASbuq6rY/n8/t6mZsa0EOLT1fm005ykJ5gVwFReR05DQri4dhVm+Q4QD6Lh83WzUAQ75GUN+MA0Br+Kbt681q1BFpULpti3xrbrbSIBLsbWIfEIBY8MBWTTkCwM7zqj27azMKgGw/7bmv6zFtriiRgpLTb912kM+ExbGJkTmfijV6wMDZZnk66mWGaVXWnn41B2m+8N4v/WuxUTPW9xuWvDdH8YPSWhf2V1FkW5z/RwBAChxkINjtdptFUwAKflnD+GsEH5Ir00tsvYI35hN92065wdyKCSXEjgTpfOTOKHMoOUqirKKmKspxZ+GG0K9YoyrTLASh1uETvbp3VUwYDwnzQqdbdCjxATyIktn45TD6ON2ruU+ELfzGvmkpAD0JbJGUxO4jC89ySnSMxXOGKQjWiFZg7huci+Qd0INJ6XOqJHJF6gkoRgHUEf16EiaF63KDwC4Xk0KviLDdG2k80MhRIhCTyGstMIJGR4DH1kCCfk1WW01ECG6qHu7cTAviImShstKhWJ+06QM41q0SBTTUDx3JiNRG+w1tkn4zspSPsBKX13i62nKRenYxAqAod12UIeyS/uKUPf37PkvsdrmRp/V59GrJuslRFKGsKOo6WDL5hONFPaVqXEqZoc676VC6jRSwFSlTvsoSOov+Ela35wkE9QJRhtki2LfazaaYCyC3ALCTlxOvBArbWC7aJpV8tQY+1P156uoVhEW0BvTM1SHUDZsFIDes2BAPqVd4GEksgsBHlwag5nLVni9cLewx4H9RqlMdQa3yNP3RFxtBIMOTAVYSY9eiy8BVALJU/Fp9TX2+ePVqDli4C63K1M7L0rlFRQygbGjwBcuBMKNA/9wlLY+8vLnAQYYupS60xSLc3NvUmvekYt9dEc98ZjRq5CHiPuEJ5VkDkq7KUiOR38yYAI1AKagbBYFYibVRJAIEG8duKAaVEKBKn2sI63g54DYgnMul/blZ0oeWl+0s+nujtBUL5N0F3usDCIV32Iz6HnWiXUOTWK3LmqHjFhLytrv75IMW+Rz6PYlKWK2As0fnrmY5cmAMN8eWYHXfREaXNSklyX0dANqElJAXy3kAHIp2UxUrt4tuxoWflhwFDmWW8e63/drhKB7HAJy1DLPTJVlocSX9hkG8VVlPCL+SLQsSSIi1ufK+8zn9nAQ4pKTplPp3s025B4or6EdyTWnSWn5MLf9W2TsXAGRVmKRpKGY0C8phaGxCGZ2Bor+afM1H6lp5e2ZMctSTniMlJbJdlMMICU8+z85p201WxBKRbWaIgDa9GMoPm0Batz3VaevVCiFICQLw8HLI3GIOilLwbKa4/muVzCRrp9SHz5oi9XNsiP0f1D3qvs+f1T/1ERiT+mYF0jiPWWjbkYxon3YZHzVT/1IDsSjO/Sj1cLUXpgnfa+7Ha3k1koOn5YnNwgn87MznmLqzWiYqU2UxK+ol3Cf5PCBpGsDnzyMI1LPVSlgVI5JMLWLOg5wPLciIu9pL6iaLtELWjjB9RNH0Ivk8isAMxmY1os0VVRcm97lUA+5zTp2/RXoAMBKL+iJHWM7u581A6zmvpyZdch9VV8ODo5Yu0M3pUSzNROssTK7yWkSfAmA2Fb3b9Ml9KPhAq5Ul86+NF03bprahvBg8Q+SY1gCAW6cjVpM6Jwf8VOZsE2priCXQ/+fJBjwhIeC+XMbuhHzQRuOkZJczB6c1jDK9DSRivqBLABGhNs/+/PKrjz/dblIslK1FnFgtJeMCCzIHAPKr/kKLmNRU6Vt4QPrBVRztQmtBI3zoRDc+KTDIiczLRMtCrJ4k4W/IRxPaez38JloDxbYJs9vhSHp4HLfLfLhneNBi076UuGvu6s3KNnKbxSbZV8GDTBqXasDRWUSboVU5BBbA6BJ41av3l1oILJyBLojVe20U6aJuPpoqJ2k0ef1GJI+DaKvASVk1XHB8eoP7EBM562PuqQpsX+fsHejvwzk4Ee9prldxdLDZHcNCMzBoQxkke5pNdNmez+89BX2LARR52cDhMEgngCglSaHY+hMyRpLlZWvYvu/796Nf2XLIcbfSYTKU9YEcW3BiAhb0mgIoWjS1b0g6Jr/vTzgMUpiEai6wU8svYgnHFF2aoj8hpgHk7wTASDR0EQBqDXSSRyfmGaDydRK0QXCfodweJQUs7cNG3b8TgnazIEYxp7FitwacVYxrX+gZ8NpQXtb4sW+0EoBzTifzS/3Dvl9jUnI45ely5nhUnED/r1ln4OUr2lNPr1imatfDXFKDO0GPsPTb33oKQCMqsnuazOpsYo7iw9zXAQCLxgDokxemYrO4recCqG9u20ACoOH3r/QqLv0UrNQSiFJ3pXVsSYLJHNC+zyDUMAfA7W3VnmfOQf3hZtOjeejPdPexfKQQtCVyjpYNT2QfGxYC55Y7R93BOVWdVHCJfDUDt7f1/YfNLEaqPyi49YLEymHYMYjWh9HyQZUQpFqBL4wRF0KQXzMINmxOFyegr25vFVnqmqG2tvo+DWJzToy9h6Inoa1BDjScHjEfEr5ZcJrbaaud14aKRXka+ZKejqqhay4Ac3N7TkE4DRxkLr8I9CE/etRtWKyMFrtxJUJ8gENLstrtbOMIWgdAXZeDgP7eIXSc4n97+Yi+2kbXPAzxCUEPg7pCXGYfzcDZah82CeD+dj6ADQWbYB8AUHpdKPc5yP68GDnJh05ImNJohU/j3FymH7hixiJAk2UziAINIgEgz6vsYzD8/igiTaKz67m73/jg4glPwYkCsBjQBHyo5wOIWehEWeikrBoTvSnrz/WvR46TkIciXSyorzHkUTzyx//UbVvrZL5VDY8L6IdJuAcErJ29BG4/VBELBQhKxpQo3WzMKD7/+tWF6euMo+pwzm/3rGXI8IAPCjsekRFG6s8f6M4yD0DdTq4Aw0TqQv994qgeEbe7ENTqG4LF3TN8oF5t2mkAlqwPjqzLil7tOSjeg04Xrl+i84f1XIQGlY8y8/CLPKWtW/qI0Y1oQDBHI2qrgf46EgOni9fzE61AwqQkZcWEeLJ6yNgTRreiuqyq0VSinuqu9/d15ffbgP4LKJ4fcZkmCwCt4oF/Jh4yrRNNBu+xRl0jZe4qLuqfSJI9gyoIwxuPFx+At6LzFQioSxd8uhdWcRKAL9PAXfK3P1zwqz9dhHDCCF7NCTF3HTwnzlJCjcWnGesIs9EreCKupP90ekQl+HigSsjLAAJZ9toTMGP4nnAZACaxr47zp9Ppuin4Owjg6/AW5eUv/4ULMbDgZMrT87UA/iow4MIb10yAmQIEgNRwkk/t9QD61+KiWeNvpgCy2BmqYWZm4FVYaDakPvRJzIHw3ycUUGW+1OuwCObtQhfWcT+bj/rrdQkti5GDiAVH32axUKhUp5fmi3aia9aALVGFj/1I+fj8KjPwpgD6Jw4jzqDgzWDOPF9Nfx/xRn9l4DvtkLikDTn3Oq1a/CozcNXGdDUDaQAczYCAzFGtjP56FQBvqAoZZQgMe4ZSvo138fHXHPJfSxbbnI+r6O9/4YAGIweXtK/lsZ0x/Nfoc6f+AoIAwCUMz08dh1I2vrqNFw2P/WvqQv3p4eGhvzwLs5dx3z8/4gPDjBS7Mb+eX3MJ9A//8+lhag4CWXwRQd8+CVwFmIWlLuUMdWiGVdm7wX34pACcZoe3L66D/lmQg90srAStfj1dmsTTFABqpCkW0h+5YieaNASfn58gnEd8o3gWHn/995ol0MN4vygRJBUciFdye3pW1D+iCKvzjdIqAYPj7oI4Gxn9/loh1o/GN9xCaNu2Ns65dlP8h0SShgYaQjIeVfLUP6a5aJr/+6ssm74PrTLsH6qLYlkMie35PeSGCl+10Ca+0nq72jn93F6DoH9hElFvQ9vhbgrxjVx7p3OT0Nt4Q16gCiQsyPPwu+rTr2fkYPVRjimvRP9SbSKhE9lkiQ06wdnIuNmGlMyWcOYkKd9g7Z6eHp+e9DBsNouifRO/imWeVJRA/9oMWZ8m+Wrb0Hpt0qecuaifpEvZwmjWbLVa5Yt6xJ7B4miGSy71xz52DtmdaAOn0WwFRig3Z9VnxknTBMpLRj3dmQP0xYiT/dz7WPtfsI+dhRDDcBbNHqcbErZ4qolIXCEfe1p2Q75BmXZJ/CUP9VMS4eRyPcwM2OMDSHvmNMjHg0YLlrO6rSmesmRt5Nl91dSbxAz4bJsCrwGBc8xc5W+ZkgUuA3NrDhbnmzqm/5VzoOhTawhyawDV105GFaaHpD8ZFA4m2aWy+2rzX+sLoda0ptm/FMMpKK22fQyrGQ8BjmR9alKbVGdvqe2M1SNBvgkZRc3700M/h5Xccxf0IP99I6C7CiTKsWhh0wZDOv3MZG+pKSgj0vtxB4QyZE40MHNSinUP7J4+znJ2D0Z5rwZAtm3ADvNVGGSoCwnBo1YWwyIwp5iu4J9ekfvphKk0lsGcQJRBgDOPzT5YNaiuDbQ9YzzV04YL6H2ms7eGFOQFzXyaCC+pvyhyFcHYNNP/v2RdQsyTBbUgzAz4Li/QSoRB3jEnaVuwFmyBA/2oOsgzmJiDgWAwZU6fxgD08cu+3yyW0QxQJpHuFBNOIkpUO9e/v7os9k17ojMw4V1/wBT3D+a//Ty5pjNGo3IB2wY1LfIs5ADgMoYC1wMc9KEqG7SqBSRgXiBf2ZJmzDXba8fEp4CjLkTCi7j2cPUVF4fxbR1Y1PSCirGhWN69q9ZNl8G5n9Dj+vOn4Xr45F6cZkYMgsIlQ92bqhGJRocGgPCNFyQpoO3bWnWNLzizKNtL/gj/7ukTuWbRb2LIZaLEjD6FFVBvZoLhVhtBhwgQabrKREGOtAID9YE5htzVp4eTG37FRaf+PGcTVRIgPEkJyhwdfikEBhA2cUG5+nyXuYNdi6pNSNxIr4Sl/DAs5X4G+Qa5PsJEj8ENkjhrOOmdYKtis3gCoPELNNrsdv5IHKvbNIRUTgQY7ZPaNNqZzSEyCmBIfcuqhvRlcW4V3EyNCzHS3E7PgXuoEjH16Fbev8gcAOdSz8oRAGXZcNr5bdCF0MbKw+LsQ7fMAcEOlzxjy/Shpr9WrNsqPgo61LkqMr8NkSaVDCplkD4/qFcnt31btrhbRt3PN3yvoH+VqA2TDwms5jwxqeyBAQjcVTbZhU+KBs9p9Zrnmtyj2k2yOo/L4W46VLnWbfqMcj33MpoHDWyUZeOLq2nJuNi85ikIU7KxrtL9GNzB2qyhw28BgFeCh1X+A3MZqtfqSd609euezdJlP5PlhQpXL7NB5ZE4FEgK3Cq4TklwCN+VkLfq1ap8PQS6/t8K6lklZ6Bad5wUvZS2whM5YEn6vHB6drepVqQqnzL0XwuCZn9UQxkDgNpP685XBva5EYwHXhXod0cxGGejLSIP1ZhWZfv3EHQ9pZWtyFDEZZFzX7V33aDAAA9yJUi/PglNoCEgYmqurG+Delir1d/uR/33zx9WU1WFXeHk7F7vQ6QKD3f1RnGDS9dwEswc1NbOIkClQUttp73MCaSJ//79x/cvq6AwMj1R7wsVbzvS2RP35IsavoDFQAAoLrrNcac0U4NwU7cvcP+oH9/77z9+/Hi4Y2FrmyJZ7jDbdVFbNQb9xnEPFEkqgCAAvOuaRdhXYLW6UTrqNaElo7op4r8bAPsvUMo6LuwB/UWLypbQRk1YmQwq38tE55RAve7WqP2MK1/75bPihvlpvIp8Tbu5HvZ7PQdjAFBLtgZVCOM+dzp0akncPgV5WCDrvdtmWRG0o7n7oglSPPH9gk5Hidef2avrS0GYKE/sQttqTY+zutzpWOshnZLjFt16M6oK2hXubr9/cASpZZl0PZ8N6frPmP4fDwcF4M7XUk4AUIqc7sLZNOA59ydYGZW7OFyWanLsCxTxbeYhFOUXPYgPaFA1O6kl6mm2vwjh9tb+QX/47gvueIR30aLabrdN5/tLc9yV2aRdikhgybGW0CiO2TS7KnM79N3eIKCc8f0HojlBuqX/bADs73ynI7Oklux2eXu7/Hj7caeGviPN7IjqyaghH7QxhnckWc+Db69ptrqpaflloH//8/x9jM4f4/SfD3uLoLRzmmVZXq2bnWabruOkMyty/g9mMROoPF5Yu0ROdk43hYX14XtL//5wOp8vI8B36LVxsp9WCCq1OWTFdt0060Z0vOP+lF6SnW2+kJTQZxCd6ua4bzyJPLnEEP1DSYWto18z0dns7nMBGKfMg//0/+qu2LumQXEWTsvH4YKQ3GerwEl6MGfoVoQd1qillv5TdzzuEQCz3czjo+/fzV4F9O+/CUn6mwti4+Li66itC+O+FRYnKnXcs0YSNdBN0PGAABysK3d80QL5gzPmhD5+OB6t+sJRg+3QbR50wWXctR4WtE17iuvcaRUONbqOBMD+BK4ipyhEW9AgJyxU8un9EVViI7aUnwt8/h/KMoioXV+CeIE/LF0Zh2+EgP0DdfZrUWCUHiMKfgy/tIDwUQP6cTUJHBuCwCuEtfCmzkTUFD5qmE57BXPfUEvdeQwI2D+MZkQkc78fws8fuIhIheGWaEVIcoYmYjFJqzLyZBqCEIeIgNM1WnVEvwYgRKrbiUDhDVwSjPldkyNjP+wwTQM4IKy/RQTsrwFwivDv//dIvxj19vG9J6VEbSCYDIrbiEClcAIadYxztamljAlQPPTn/OffP38sjerlNfTrRUA4R8rE4pTQyEIDkD7AgcQX7fpNOh47WSKP3xIU7H/+37/6MnT/+0e/dFjCBZD6tEJAuR5aLWG9mXu9yAMIFSEnjKknkqNmrfEKHgAYog3d//pX9rWdFAVPXb+TH98facoD+EckEay4ExBHBW9ocAY1SIkb3h8PaQD/Tlx/LAD9Mk3//uA2aQ7t2XGCNy3PaYx6VKoBd2viAn1aSOhGODw3uQIMBX8mEHjyxyZA8RA9W2gSLCE5PWgY5QHwpEIqU6LN3XEcoWByDhy4Ufo9D0EGHzRu56QBn/PMef4Poq1oK4oanSoGGuGgS1Ng6f85Sv/+0MGGGPsVwpb1jEP91yA0GTRzlajRnZrVcfr3+9+XEPyZ+LBGIAVpIygTETyf/I1LzEUMBL103bl1r4R+m6Dg5yUEf/aTAI4CR5EkbdfIodmMSzVA3YyisRfQV4E0eTlOkvBzGsDvyQkYVgHnsWE4nNOQtNaiIBPAqUsdV72R3hjSeI7TNPx+OQNpABKXk4POw9DoGle/t6YkCR1woFiCKHZ2pJ6ACwAmhcHvC/Tvv2GPFC2mggwcD0AkYvUQ1JAgx9A6OF4axJ8vXQBuCqK8Bx+btwE+7kpU8ahuuRNiuKEC6piu/3S4SMPPl+ygZBUgVwKqGI97Lg0GDY9Wr8voGm5Gxf09guNlAPs/Y/Qf5gBI7ui0Gx+qeswTCQZhTwuSsDkHwP6QEmh/ZjCQ30ljK55HBjCj2lpsBsmwbaJ+fdjPI+P3y8Z/kMbEGToyExYAVNKW3uSX5DbKRmI/9/r9Rxs3WgX6Y67D3A8eOck1EXHcFJWslcgByoObpAhaeJsXswHsDz9/Hg6/1aV+qf/N/xwxvoQMTTJfGYwJ0lMk7G7NaZMsB2k+IS++/om84pKws9uWmETdCECKxb4KzHzHdwCQ6OiO++5BE5Fw0K2ckN6BwcGzeMEWe9XriIoxo/7cEpdH4qhLehTM4ESf8za1vvO4f4frQCxcHOmVAvenZIEXTNISvMRH6tzr7zEBRpbh/pMcL0iv4nGXK8G5EGPSwp/pcDbGuwA4HHCFaU6cPt51PrS4JgYkD/yKZtnT0IF4FxbaH+w65EGVXa8iDKiY1y2ieDHYMJz4N+ThfQD4DqU8kk7gMzQBjkQgUlI7TgooZBW51N9sFYtkFmgIzQQCOQAAAthJREFUIHHmBPmC4JQ0Cn68EwsdkeXCg158Urr8IIb8hTyhLoEK6ivbvhMLDdoE5KajLHVnHbtikdbe5Dzq1ITsMt9U9J3WsNPncKoo1BOVuEu6A0BNGx8SIGqQzsU/vBsAVNAeB1y9maKZhoHXOpnHjjzCztn6XjNwOOK4qhRh61KYAdfeF2330foHaMd3BMAFx+lWPqkVm5SSjwX2vJLtVVOZ1uTu3m4GgmArHfwhQgOVvyn3cJQGiBH/EwG4u3sNBHfRY4CFZOj04UGYFWVLhGnUwemIhFPx7u5VECSecvxH0A1e+qQHlL1ONc04O4soe3qxHN4OwN1IoID6RgXJFB0OQEC/4sAFwLGtbJ7wz7c34aDEFByOnfdHg0VMh9WlnNnFGhdnj/xL/I2WQOI5h29HGDwcnkDhDw0gOAAUnCYg7Y/06+P+/WYAVHysjHGst9nzAyPmDA/TRzWcw3sBUGvAboGcCjCOmJozYqy5HRQ14ORB/6P3YyHtZZfWw4+dK/ism+nJJ5H3DsIHKKEXmdby7QDED/omgkx1FMTz9jJD7UOQupF0B73tDCRW8T/Yp4JYBdv6DOSc5TZOLEweAZghgV5JEBzAUidzgBtHBen3HCU3QeUDtE/JODr5mgDSHl5vq6CUDpJq4Med+OKkDDNwzHB8eyP6k6JYBk0zUXzMN1Dg6ExQwhdP8jxS8eG711wDEwCkoAfPOS4Og48HBHo1D44UvNkSSEkykiqA430Cwq2M5iHwRJkJiVyMSU3izQAcBTG/4EQ9Ps1KnS8+tWUkc/SdAUhIciaZcbCmfU8+zFnWiR22vn5/AB0JMgauUoGS/gQxHAXJrQuudwXgI/PkEDTYt6YHB0rik8SElBK5e8GgfMdFrCwycvyZyGKrFEkWp9TRxCYyCm8KINIlDv/oxFFU1BjXIHE+XYa9b37fpFFhdGrjnzczB9K7EMcASDTMMcb/A9C/dRL10NfSAAAAAElFTkSuQmCC",
                 @"dl-categories" : @[
                         @{@"name" : @"二･小･原", @"licensed" : @true, @"tag" : @"0x22", @"date" : @"平成17年03月02日"},
                         @{@"name" : @"他", @"licensed" : @true, @"tag" : @"0x23", @"date" : @"平成21年11月07日"},
                         @{@"name" : @"二種", @"licensed" : @true, @"tag" : @"0x24", @"date" : @"昭和09年05月13日"},
                         ],
                 @"dl-remarks" : @""  // 備考
                 };
    } else if ([self.currentModel.kbnModel.name isEqualToString:@"マイナンバーカード"]) {
        return @{
                 @"cardinfo-name": @"日本　花子",
                 @"cardinfo-birth": @"19750601",
                 @"cardinfo-addr": @"東京都千代田区霞が関２−１−２",
                 @"cardinfo-sex": @"女性",
                 @"cardinfo-mynumber": @"123456789012",
                 @"cardinfo-cert-expire": @"20200601235959",
                 @"cardinfo-expire": @"20250601",
                 @"cardinfo-photo": @"data:image/png;base64,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"
                 };
    } else if ([self.currentModel.kbnModel.name isEqualToString:@"パスポート"]) {
        return @{
                 @"ep-type": @"P<",
                 @"ep-issuing-country": @"JPN",
                 @"ep-passport-number": @"TRXXXXXXX",
                 @"ep-surname": @"NIHON",
                 @"ep-given-name": @"HANAKO",
                 @"ep-nationality": @"JPN",
                 @"ep-date-of-birth": @"750601",
                 @"ep-sex": @"F",
                 @"ep-date-of-expiry": @"170601",
                 @"ep-mrz": @"P<JPNNIHON<<HANAKO<<<<<<<<<<<<<<<<<<<<<<<<<<TRXXXXXXXXJPN750601XF170601X<<<<<<<<<<<<<<XX",
                 @"ep-bac-result": @true,
                 @"ep-aa-result": @true,
                 @"ep-pa-result": @true,
                 @"ep-photo": @"data:image/png;base64,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"
                 };
    } else {
        return @{
                 @"showcert-subject": @"CN=XXXXXXXXXXXXXXXXXXXXX, C=JP",
                 @"showcert-issuer": @"OU=Japan Agency for Local Authority Information Systems, OU=JPKI for user authentication, O=JPKI, C=JP",
                 @"showcert-not-before": @"Thu Jul 02 00:00:00 GMT+9:00 2016",
                 @"showcert-not-after": @"Mon Jun 01 23:59:59 GMT+9:00 2020",
                 @"showcert-serial-number": @"XXXXXXX (0xXXXXXX)",
                 @"showcert-version": @"3",
                 @"showcert-public-key-alg": @"RSA",
                 @"showcert-public-key-alg-params": @"NULL",
                 @"showcert-public-key-rsa-size": @"2048 bit",
                 @"showcert-public-key-rsa-modulus": @"(RSA モジュラスの内容)",
                 @"showcert-public-key-rsa-exponent": @"65537 (0x10001)",
                 @"showcert-public-key": @"(公開鍵の内容)",
                 @"showcert-subject-key-identifier": @"(サブジェクトキー識別子の内容)",
                 @"showcert-key-usage": @"(キー使用法の内容)",
                 @"showcert-subject-alt-name": @"(サブジェクト代替名の内容)",
                 @"showcert-issuer-alt-name": @"(発行者の別名の内容)",
                 @"showcert-basic-constraints": @"(基本制限の内容)",
                 @"showcert-crl-distribution-point": @"(CRL配布ポイントの内容)",
                 @"showcert-certificate-policies": @"(証明書ポリシーの内容)",
                 @"showcert-authority-key-identifier": @"(機関キー識別子の内容)",
                 @"showcert-extended-key-usage": @"(拡張キー使用法の内容)",
                 @"showcert-authority-information-access": @"(機関情報アクセスの内容)",
                 @"showcert-sig-alg": @"SHA256WITHRSA",
                 @"showcert-sig-alg-params": @"NULL",
                 @"showcert-fingerprint-sha1": @"(SHA1フィンガープリントの内容)",
                 @"showcert-signature": @"XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX(以下略)",
                 @"showcert-fingerprint-sha1": @"(SHA1フィンガープリントの内容)",
                 @"showcert-fingerprint-sha256": @"(SHA256フィンガープリントの内容)",
                 @"showcert-unsupported-oid0": @"2.5.29.XX",
                 @"showcert-unsupported-oid0-value": @"(2.5.29.XXの内容)"
                 };
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
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
