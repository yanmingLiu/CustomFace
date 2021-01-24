//
//  ViewController.m
//  自定义表情包
//
//  Created by 张祎 on 17/2/22.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "ViewController.h"
#import "ZYFaceBoard.h"
#import "NSAttributedString+zy_string.h"
#import "ZYFaceHelper.h"

@interface ViewController () <ZYFaceBoardProtocol, UITextViewDelegate>
@property(nonatomic, strong) ZYFaceBoard *faceBoard;
@property (strong, nonatomic) IBOutlet UIButton *faceButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextView *textView2;
@property(nonatomic, assign) BOOL keyBoardFlag;

@property (weak, nonatomic) IBOutlet UITextView *textView3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLayoutH;

@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *typingAttributes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = self;
    
    self.textView2.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView2.layer.borderWidth = 0.5;
    self.textView2.delegate = self;
    self.textView2.editable = NO;
    
    self.faceBoard = [[ZYFaceBoard alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 250) textView:self.textView];
    self.faceBoard.backgroundColor = [UIColor redColor];
    self.faceBoard.delegate = self;
    
    [self setupTypingAttributes];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setupTextView3];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.textView3 setContentOffset:CGPointZero animated:NO];
}

- (void)setupTextView3 {
    self.textView3.scrollEnabled = NO;
    self.textView3.pagingEnabled = NO;
    self.textView3.editable = NO;
    
    self.textView3.textAlignment = NSTextAlignmentLeft;
    self.textView3.textContainer.lineFragmentPadding = 0;
    
    self.textView3.contentInset = UIEdgeInsetsZero;
    
    // 文字下移 需要设置textContainerInset, 而不是上面的contentInset
    self.textView3.textContainerInset = UIEdgeInsetsZero;
}

- (void)refreshTextView3 {
    CGFloat height = [self.textView.attributedText heightOfWidth:[UIScreen mainScreen].bounds.size.width - 16 * 2];
    
    self.textView3.attributedText = self.textView.attributedText;
    
    self.textViewLayoutH.constant = height + self.textView3.contentInset.top + self.textView3.contentInset.bottom;
    
    NSLog(@"textview3的高度 = %f", self.textViewLayoutH.constant);
    NSLog(@"textview3的内容大小 = %@", NSStringFromCGSize(self.textView3.contentSize));
}

- (void)setupTypingAttributes {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    // NSForegroundColorAttributeName —— 字体颜色
    dic[NSForegroundColorAttributeName] = [UIColor blueColor];
    
    // NSBackgroundColorAttributeName —— 背景色
    dic[NSBackgroundColorAttributeName] = [UIColor orangeColor];

    
    // 创建NSMutableParagraphStyle实例 文本字、行间距，对齐等
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;       //字间距5
    paragraphStyle.paragraphSpacing = 20;       //行间距是20
    paragraphStyle.alignment = NSTextAlignmentLeft;   //对齐方式
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    
    // NSBaselineOffsetAttributeName —— 基础偏移量 注意：正值向上偏移，负值向下偏移，默认0（不偏移）
    
    
    // NSLigatureAttributeName —— 连字符
    
    // NSKernAttributeName —— 字符间距 正值间距加宽，负值间距变窄，0表示默认效果
    
    // NSStrikethroughStyleAttributeName —— 删除线
    // NSStrikethroughColorAttributeName —— 删除线颜色
    
    // NSUnderlineStyleAttributeName —— 下划线
    // NSUnderlineColorAttributeName —— 下划线颜色
    
    // NSStrokeColorAttributeName —— 描边颜色
    // NSStrokeWidthAttributeName —— 描边宽度
    
    // NSShadowAttributeName —— 文本阴影
    
    // NSTextEffectAttributeName —— 文字效果
    
    // NSLinkAttributeName —— 链接
    
    self.typingAttributes = dic;
}

/** 下面输出的文字可用于上传服务器 */


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView == self.textView) {
        textView.typingAttributes = self.typingAttributes;
    }
    
    return true;
}


//文字变化
- (void)textViewDidChange:(UITextView *)textView {

    //这个字符串可上传服务器
    NSString *serverString = [textView.attributedText toString];
    //表情纯文本
    self.textView2.text = serverString;
    NSLog(@"传到服务器:%@", serverString);
    
    //    //从服务器纯文本转换回来的表情富文本
    //NSAttributedString *converString = [[ZYFaceHelper new] faceWithServerString:serverString];
    
    [self refreshTextView3];
}

//表情变化
- (void)zy_faceDidChanged:(NSAttributedString *)attributedString {
    
    //这个字符串可上传服务器
    NSString *serverString = [self.textView.attributedText toString];
    //表情纯文本
    self.textView2.text = serverString;
    NSLog(@"传到服务器:%@", serverString);
    
    [self refreshTextView3];
}


- (IBAction)faceButton:(id)sender {
    
    if (!_keyBoardFlag) {
        
        [self.view endEditing:YES];
        self.textView.inputView = self.faceBoard;
        [self.textView becomeFirstResponder];
        [self.faceButton setImage:[UIImage imageNamed:@"键盘"] forState:UIControlStateNormal];
    }
    
    else {
        
        [self.view endEditing:YES];
        self.textView.inputView = nil;
        [self.textView becomeFirstResponder];
        [self.faceButton setImage:[UIImage imageNamed:@"表情"] forState:UIControlStateNormal];
    }
    
    _keyBoardFlag = !_keyBoardFlag;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
