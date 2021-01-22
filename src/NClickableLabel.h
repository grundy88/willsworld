
@interface NClickableLabel : UIView {
    UILabel *label;
	NSObject *target;
	SEL selector;
}

@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) NSObject *target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, copy) NSString *text;
@property (nonatomic) UITextAlignment textAlignment;

@end
