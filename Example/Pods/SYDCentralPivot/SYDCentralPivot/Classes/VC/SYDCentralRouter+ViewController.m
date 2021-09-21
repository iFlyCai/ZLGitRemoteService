#import "SYDCentralRouter+ViewController.h"
#import "SYDCentralFactory+ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation SYDCentralRouter (ViewController)

- (void) enterViewController:(const NSString *) viewControllerKey withViewControllerConfig:(id) config withParam:(NSDictionary *) paramDic
{
    SYDLog(@"SYDCentralRouter_enterViewController: viewControllerKey[%@] config[%@] paramDic[%@]",viewControllerKey,config,paramDic);
    
    Class viewControllerClass = [self.centralFactory getViewControllerClass:viewControllerKey];
    
    if(!viewControllerClass)
    {
        SYDLog(@"SYDCentralRouter_enterViewController: viewcontrollerclass for [%@] not exist",viewControllerKey);
        return;
    }
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    
    SEL enterViewControllerSEL = @selector(enterViewControllerWithViewControllerConfig:withParam:);

    #pragma clang diagnostic pop
    
    
    Method enterViewControllerMethod = class_getClassMethod(viewControllerClass,enterViewControllerSEL);
    
    void(*enterViewController)(id,SEL,id,NSDictionary *) = (void(*)(id,SEL,id,NSDictionary *))method_getImplementation(enterViewControllerMethod);
    
    if(enterViewController)
    {
        enterViewController(viewControllerClass,
                            enterViewControllerSEL,
                            config,
                            paramDic);
    }
    else
    {
        SYDLog(@"SYDCentralRouter: enterViewController method for [%@] not exist ",viewControllerKey);
    }
}


@end
