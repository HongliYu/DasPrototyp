//
//  GDStyle.m
//  DuiTang
//
//  Created by ls on 14-8-13.
//
//

#import "GDUIViewStyleMaker.h"
#import <objc/runtime.h>


@interface UIView (Border)

@property (nonatomic, strong) CALayer *bottomBorderLayer;
@property (nonatomic, strong) CALayer *rightBorderLayer;
@property (nonatomic, strong) CALayer *leftBorderLayer;
@property (nonatomic, strong) CALayer *topBorderLayer;

@end

static char UIViewBottomBorder;
static char UIViewRightBorder;
static char UIViewLeftBorder;
static char UIViewTopBorder;

@implementation UIView(Border)

@dynamic bottomBorderLayer, rightBorderLayer, leftBorderLayer;

- (void)setBottomBorderLayer:(CALayer *)bottomBorderLayer {
  [self willChangeValueForKey:@"bottomBorderLayer"];
  objc_setAssociatedObject(self, &UIViewBottomBorder,
                           bottomBorderLayer,
                           OBJC_ASSOCIATION_RETAIN);
  [self didChangeValueForKey:@"bottomBorderLayer"];
}

- (void)setRightBorderLayer:(CALayer *)rightBorderLayer {
  [self willChangeValueForKey:@"rightBorderLayer"];
  objc_setAssociatedObject(self, &UIViewRightBorder,
                           rightBorderLayer,
                           OBJC_ASSOCIATION_RETAIN);
  [self didChangeValueForKey:@"rightBorderLayer"];
}

- (void)setLeftBorderLayer:(CALayer *)leftBorderLayer {
  [self willChangeValueForKey:@"leftBorderLayer"];
  objc_setAssociatedObject(self, &UIViewLeftBorder,
                           leftBorderLayer,
                           OBJC_ASSOCIATION_RETAIN);
  [self didChangeValueForKey:@"leftBorderLayer"];
}

- (void)setTopBorderLayer:(CALayer *)topBorderLayer {
  [self willChangeValueForKey:@"topBorderLayer"];
  objc_setAssociatedObject(self, &UIViewTopBorder,
                           topBorderLayer,
                           OBJC_ASSOCIATION_RETAIN);
  [self didChangeValueForKey:@"topBorderLayer"];
}

- (CALayer *)bottomBorderLayer {
  return objc_getAssociatedObject(self, &UIViewBottomBorder);
}

- (CALayer *)rightBorderLayer {
  return objc_getAssociatedObject(self, &UIViewRightBorder);
}

- (CALayer *)leftBorderLayer {
  return objc_getAssociatedObject(self, &UIViewLeftBorder);
}

- (CALayer *)topBorderLayer {
  return objc_getAssociatedObject(self, &UIViewTopBorder);
}

@end

@interface GDUIViewStyleMaker()

@property (nonatomic, strong) UIView *view;

@end

@implementation GDUIViewStyleMaker


- (id)initWithView:(UIView *)view {
  if (self = [super init]) {
    self.view = view;
  }
  return self;
}


- (GDUIViewStyleMaker * (^)(CGFloat))width {
  return ^id(CGFloat attribute) {
    self.view.width = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGFloat))height {
  return ^id(CGFloat attribute) {
    self.view.height = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGFloat))right {
  return ^id(CGFloat attribute) {
    self.view.right = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGFloat))left {
  return ^id(CGFloat attribute) {
    self.view.left = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGFloat))top {
  return ^id(CGFloat attribute) {
    self.view.top = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGFloat))bottom {
  return ^id(CGFloat attribute) {
    self.view.bottom = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGRect))frame {
  return ^id(CGRect attribute) {
    self.view.frame = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIViewAutoresizing))autoresizingMask {
  return ^id(UIViewAutoresizing attribute) {
  self.view.autoresizingMask = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIImage *))image {
    return ^id(UIImage *attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UIImageView class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIImageView *imageView = (UIImageView *)self.view;
  imageView.image = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIFont *))font {
    return ^id(UIFont *attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UILabel class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UILabel *label = (UILabel *)self.view;
  label.font = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(NSInteger))numberOfLines {
    return ^id(NSInteger attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UILabel class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UILabel *label = (UILabel *)self.view;
  label.numberOfLines = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *))textColor {
    return ^id(UIColor *attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UILabel class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UILabel *label = (UILabel *)self.view;
  label.textColor = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *))backgroundColor {
  return ^id(UIColor *attribute) {
    self.view.backgroundColor = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(NSLineBreakMode ))lineBreakMode {
    return ^id(NSLineBreakMode attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UILabel class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UILabel *label = (UILabel *)self.view;
  label.lineBreakMode = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(void ))sizeToFit {
  return ^id(void) {
    [self.view sizeToFit];
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(CGPoint))center {
  return ^id(CGPoint attribute) {
    self.view.center = attribute;
    return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIFont *))titleFont {
    return ^id(UIFont *attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  button.titleLabel.font = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(NSLineBreakMode ))titleLineBreakMode {
    return ^id(NSLineBreakMode attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  button.titleLabel.lineBreakMode = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIControlContentHorizontalAlignment ))contentHorizontalAlignment {
    return ^id(UIControlContentHorizontalAlignment attribute) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  button.contentHorizontalAlignment = attribute;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *, UIControlState))titleColor {
    return ^id(UIColor *attribute, UIControlState attribute1) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  [button setTitleColor:attribute forState:attribute1];
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIImage *, UIControlState))backgroundImage {
    return ^id(UIImage *attribute, UIControlState attribute1) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  [button setBackgroundImage:attribute forState:attribute1];
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIImage *, UIControlState))buttonImage {
    return ^id(UIImage *attribute, UIControlState attribute1) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  [button setImage:attribute forState:attribute1];
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIEdgeInsets))titleEdgeInsets {
    return ^id(UIEdgeInsets insets) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  button.titleEdgeInsets = insets;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIEdgeInsets))imageEdgeInsets {
    return ^id(UIEdgeInsets insets) {
#ifdef POP_DEBUG
  Class targetClass = [UIButton class];
  NSString *errorMessage = [NSString stringWithFormat:@"View must class of %@", NSStringFromClass(targetClass)];
  NSAssert([self.view isKindOfClass:targetClass], errorMessage);
#endif
  UIButton *button = (UIButton *)self.view;
  button.imageEdgeInsets = insets;
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))topBorder {
    return ^id(UIColor *color, CGFloat width) {
  if (self.view.topBorderLayer == nil || ![self.view.topBorderLayer isKindOfClass:[CALayer class]]) {
    self.view.topBorderLayer = [CALayer layer];
    [self.view.layer addSublayer:self.view.topBorderLayer];
  }
  CALayer *border = self.view.topBorderLayer;
  border.backgroundColor = color.CGColor;
  border.frame = CGRectMake(0, 0, self.view.frame.size.width, width);
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))bottomBorder {
    return ^id(UIColor *color, CGFloat width) {
  if (self.view.bottomBorderLayer == nil || ![self.view.bottomBorderLayer isKindOfClass:[CALayer class]]) {
    self.view.bottomBorderLayer = [CALayer layer];
    [self.view.layer addSublayer:self.view.bottomBorderLayer];
  }
  CALayer *border = self.view.bottomBorderLayer;
  border.backgroundColor = color.CGColor;
  border.frame = CGRectMake(0, self.view.frame.size.height - width, self.view.frame.size.width, width);
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))rightBorder {
    return ^id(UIColor *color, CGFloat borderWidth) {
  if (self.view.rightBorderLayer == nil
      || ![self.view.rightBorderLayer isKindOfClass:[CALayer class]]) {
    self.view.rightBorderLayer = [CALayer layer];
    [self.view.layer addSublayer:self.view.rightBorderLayer];
  }
  CALayer *border = self.view.rightBorderLayer;
  border.backgroundColor = color.CGColor;
  border.frame = CGRectMake(self.view.frame.size.width - borderWidth, 0, borderWidth, self.view.frame.size.height);
  return self;
  };
}

- (GDUIViewStyleMaker * (^)(UIColor *, CGFloat))leftBorder {
    return ^id(UIColor *color, CGFloat borderWidth) {
  if (self.view.leftBorderLayer == nil
      || ![self.view.leftBorderLayer isKindOfClass:[CALayer class]]) {
    self.view.leftBorderLayer = [CALayer layer];
    [self.view.layer addSublayer:self.view.leftBorderLayer];
  }
  CALayer *border = self.view.leftBorderLayer;
  border.backgroundColor = color.CGColor;
  border.frame = CGRectMake(0, 0, borderWidth, self.view.frame.size.height);
  return self;
  };
}

@end
