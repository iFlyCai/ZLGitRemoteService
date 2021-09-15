
#import "SYDCentralFactory+ViewController.h"
#import "UIViewController+SYDRouter.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation SYDCentralFactory (ViewController)

- (Class) getViewControllerClass:(const NSString *) viewControllerKey{
    Class cla = [self getBeanClass:viewControllerKey];
    if([cla isSubclassOfClass:[UIViewController class]]){
        return cla;
    } else {
        return nil;
    }
}

- (UIViewController *) getOneUIViewController:(const NSString *) viewControllerKey{
    
    Class viewControllerClass = [self getViewControllerClass:viewControllerKey];
    
    if(!viewControllerClass){
       NSLog(@"SYDCentralFactory_getOneUIViewController: class for [%@] is not exist",viewControllerKey);
        return nil;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    SEL getOneViewControllerSEL = @selector(getOneViewController);
    SEL setVCKEYSEL = @selector(setVCKey:);
    
#pragma clang diagnostic pop
    
    Method getOneViewControllerMethod = class_getClassMethod(viewControllerClass,getOneViewControllerSEL);
    Method setVCKEYMethod = class_getInstanceMethod(viewControllerClass,setVCKEYSEL);
    
    UIViewController *(*getOneViewController)(id,SEL) = (UIViewController * (*)(id,SEL))method_getImplementation(getOneViewControllerMethod);
    void (*setVCKey)(id,SEL,const NSString *) = (void (*)(id,SEL,const NSString *))method_getImplementation(setVCKEYMethod);
    
    if(getOneViewController && setVCKey){
        UIViewController *controller  = getOneViewController(viewControllerClass,
                                                             getOneViewControllerSEL);
        setVCKey(controller,setVCKEYSEL,viewControllerKey);
        return controller;
    }
    else{
        NSLog(@"SYDCentralFactory_getOneViewController: method for [%@] not exist ",viewControllerKey);
        return class_createInstance(viewControllerClass, 0);
    }
}


- (UIViewController *) getOneUIViewController:(const NSString *) viewControllerKey withInjectParam:(NSDictionary *) param
{
    UIViewController * viewController = [self getOneUIViewController:viewControllerKey];
    
    if(viewController)
    {
        [param enumerateKeysAndObjectsUsingBlock:^(id key,id value,BOOL * stop)
         {
             NSString * tmpKey = key;
             @try
             {
                 [viewController setValue:value forKey:tmpKey];
             }
             @catch(NSException * exception)
             {
                 NSLog(@"SYDCentralFactory_getOneUIViewControllerWithInjectParam: value for key[%@] not exist,exception[%@]",viewControllerKey,exception);
             }
             
         }];
    }

    return viewController;
}

@end
