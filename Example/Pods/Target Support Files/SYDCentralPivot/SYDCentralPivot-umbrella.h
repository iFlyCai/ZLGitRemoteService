#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SYDCentralFactory.h"
#import "SYDCentralPivot.h"
#import "SYDCentralRouter.h"
#import "SYDCentralRouterModel.h"
#import "SYDCentralFactory+ViewController.h"
#import "SYDCentralPivotForVC.h"
#import "SYDCentralRouter+ViewController.h"
#import "SYDCentralRouterViewControllerConfig.h"
#import "UIViewController+SYDRouter.h"

FOUNDATION_EXPORT double SYDCentralPivotVersionNumber;
FOUNDATION_EXPORT const unsigned char SYDCentralPivotVersionString[];

