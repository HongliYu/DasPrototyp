//
//  DPMainMacro.h
//  DasPrototyp
//
//  Created by HongliYu on 14-6-24.
//  Copyright (c) 2014年 HongliYu. All rights reserved.
//

#define NavigationBar_HEIGHT 44.0f
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_PROPORTION (([UIScreen mainScreen].bounds.size.width)/([UIScreen mainScreen].bounds.size.height))
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion ([[UIDevice currentDevice] systemVersion])
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

// Device screen
#define DEVICE_IS_IPHONE4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define DEVICE_IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define DEVICE_IS_IPHONE6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define DEVICE_IS_IPHONE6_PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define DEVICE_IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//GCD
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

//DPColors
#define BACKGROUND_COLOR [UIColor colorWithRed:242.0/255.0 green:236.0/255.0 blue:231.0/255.0 alpha:1.0]
#define FONT_COLOR [UIColor colorWithRed:86/255.0 green:202/255.0 blue:139/255.0 alpha:1.0]

#define MAIN_COLOR [UIColor colorWithRed:237.0/255.0 green:140.0/255.0 blue:52.0/255.0 alpha:1.0]
#define MAIN_BLUE_COLOR [UIColor colorWithRed:106.0f/255.0f green:155.0f/255.0f blue:237.0f/255.0f alpha:1.0f]
#define MAIN_PINK_COLOR [UIColor colorWithRed:237.0/255.0 green:140/255.0 blue:200/255.0 alpha:1.0f]
#define MAIN_RED_COLOR [UIColor colorWithRed:237.0/255.0 green:100/255.0 blue:100/255.0f alpha:1.0f]
#define MAIN_GREEN_COLOR [UIColor colorWithRed:86/255.0 green:202/255.0 blue:139/255.0 alpha:1.0]

//Load images
#define IMAGE_NAMED(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]
#define LOAD_IMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

// UIColorFromRGB(0xffffff);
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// UIFont
#define SET_FONT(className,fontName,fontSize) [className setFont:[UIFont fontWithName:fontName size:fontSize]]

// DOCUMENTS_DIRECTORY
#define DOCUMENTS_DIRECTORY [[[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] relativePath]

// Singleton
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+(className* )shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
@synchronized(self){ \
shared##className = [[self alloc] init]; \
} \
}); \
return shared##className; \
}

#ifdef POP_DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #define MARK    NSLog(@"\nMARK: %s, %d", __PRETTY_FUNCTION__, __LINE__)
#else
    #define DLog(...)
#endif
