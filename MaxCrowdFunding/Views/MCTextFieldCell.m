//
//  MCTextFieldCell.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCTextFieldCell.h"

NSString * const kTitle = @"title";
NSString * const kValue = @"value";
NSString * const kPlaceHolder = @"placeHolder";

@interface MCTextFieldCell () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputField;
@end

@implementation MCTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.inputField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelH = height - border * 2;
    CGFloat labelW = 80;
    self.titleLabel.frame = CGRectMake(border, border, labelW, labelH);
    
    CGFloat fieldX = CGRectGetMaxX(self.titleLabel.frame) + 5;
    CGFloat fieldW = width - fieldX - border;
    self.inputField.frame = CGRectMake(fieldX, border, fieldW, labelH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    self.titleLabel.text = dic[kTitle];
    self.inputField.text = dic[kValue];
    self.inputField.placeholder = dic[kPlaceHolder];
}

- (NSDictionary *)contentDic {
    NSString *placeHolder = self.inputField.placeholder ? self.inputField.placeholder : @"";
    NSDictionary *dic = @{
                kTitle: self.titleLabel.text,
                kValue: self.inputField.text,
          kPlaceHolder: placeHolder
                          };
    return dic;
}

#pragma mark - delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCell:didStartEdit:)]) {
        [self.delegate textFieldCell:self didStartEdit:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCell:didEndEdit:)]) {
        [self.delegate textFieldCell:self didEndEdit:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _titleLabel;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] init];
        _inputField.delegate = self;
    }
    return _inputField;
}


@end
