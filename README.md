# Swift CocoaPods开发 - 原理篇 

创建的Swift Pod私有库依赖了百度地图，在`podspec`文件中添加了`s.dependency "BaiduMapKit"`，但是仍旧无法引用百度地图的头文件`import BaiduMapAPI_Map`。

#### 解决思路

1. `BaiduMapKit`使用OC编写的，并且是以`framework`形式打包的`静态库`。在Swift项目中引用OC的头文件，想到的就是创建桥接文件`Bridging-Header.h`，并在`Build Settings`中`SWIFT_OBJC_BRIDGING_HEADER`指定桥接文件的路径，所以我在`podspec`文件添加了：
        
    ```
    s.pod_target_xcconfig = {
      # 这个路径根据实际情况去设置
      'SWIFT_OBJC_BRIDGING_HEADER' => 'YMTest/Classes/Bridging-Header.h'
    }
    ```
    
    `Bridging-Header.h`内容如下
    ```
    #import <BaiduMapAPI_Base/BMKBaseComponent.h>
    #import <BaiduMapAPI_Map/BMKMapComponent.h>
    #import <BaiduMapAPI_Search/BMKSearchComponent.h>
    #import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
    #import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
    #import <BaiduMapAPI_Map/BMKMapView.h>
    ```
    
    接下来编译项目，报错：
    ```
    using bridging headers with framework targets is unsupported
    ```
    **framework不支持桥接文件！！！**
    
1. 在[Apple Developer Forums](https://forums.developer.apple.com/thread/10419)中给出了原因：

    ```
    As the error says, bridging headers aren't allowed in frameworks, 
    only in applications.
    //
    The Swift code will be able to access everything from objc that 
    is included in the public umbrella header for your framework where 
    it says
    ```
    
1. 解决方法可以参考[Importing CommonCrypto in a Swift framework](https://stackoverflow.com/questions/25248598/importing-commoncrypto-in-a-swift-framework/29189873#29189873)，我简单总结下：

    **知识点：如果想在Swift Framework中引用OC框架（已生成的静态库/动态库，非源码），我们需要使用module.modulemap，这个文件用来描述module与headers之间映射关系（有些第三方你拉取下来发现就已经有了这个文件就不会有这个问题，但是百度sdk目前就没有，所以要我们自己完成这个文件）**

    以`BaiduMapKit`（版本5.2.0）为例，目录结构如下：
    
    ```
    ├── BaiduMapAPI_Base.framework
    │   ├── BaiduMapAPI_Base
    │   ├── Headers
    ├── BaiduMapAPI_Cloud.framework
    │   ├── BaiduMapAPI_Cloud
    │   ├── Headers
    ├── BaiduMapAPI_Map.framework
    │   ├── BaiduMapAPI_Map
    │   ├── Headers
    │   └── mapapi.bundle
    ├── BaiduMapAPI_Search.framework
    │   ├── BaiduMapAPI_Search
    │   ├── Headers
    ├── BaiduMapAPI_Utils.framework
    │   ├── BaiduMapAPI_Utils
    │   ├── Headers
    └── thirdlibs
        ├── libcrypto.a
        └── libssl.a
    ```
    
    发现`BaiduMapKit`里的framework并没有`module.modulemap`这个文件，所以这就导致在Swift Pod开发中，无法import百度的头文件，所以我们必须手动的添加这个文件。

    以`BaiduMapAPI_Base.framework`为例，其它的类似：
    
    1. 进入`BaiduMapAPI_Base.framework`目录，新建文件夹`Modules`，并在`Modules`下新建文件`module.modulemap`；
    
    2. 打开`module.modulemap`，复制下面内容：

        ```
        framework module BaiduMapAPI_Base {
            header "BMKBaseComponent.h"
            header "BMKGeneralDelegate.h"
            header "BMKMapManager.h"
            header "BMKTypes.h"
            header "BMKUserLocation.h"
            header "BMKVersion.h"
            export *
        }
        ```
        
        `header`是framework中`Headers`文件夹下的文件。
        ***工程里的mk_modulemap.sh脚本已经在SwiftPodsDemo.podspec添加了执行，所以本工程在pod install时候会自动生成上面的module.modulemap***
        修改后的目录结构
        
        ```
        ├── BaiduMapAPI_Base.framework
        │   ├── BaiduMapAPI_Base
        │   ├── Headers
        │   └── Modules
        │       └── module.modulemap
        ├── BaiduMapAPI_Cloud.framework
        │   ├── BaiduMapAPI_Cloud
        │   ├── Headers
        │   └── Modules
        │       └── module.modulemap
        ├── BaiduMapAPI_Map.framework
        │   ├── BaiduMapAPI_Map
        │   ├── Headers
        │   ├── Modules
        │   │   └── module.modulemap
        │   └── mapapi.bundle
        ├── BaiduMapAPI_Search.framework
        │   ├── BaiduMapAPI_Search
        │   ├── Headers
        │   └── Modules
        │       └── module.modulemap
        ├── BaiduMapAPI_Utils.framework
        │   ├── BaiduMapAPI_Utils
        │   ├── Headers
        │   └── Modules
        │       └── module.modulemap
        └── thirdlibs
            ├── libcrypto.a
            └── libssl.a
        ```
     
1. 然后`pod install`，报错（截取核心部分）：
    
    ```
    target has transitive dependencies that include statically linked binaries:
    ```
    **知识点：上面提到，百度地图是一个静态库，以framework方式进行打包，而Swift framework默认是动态库（默认的Swift项目podfile使用了use_frameworks!），这个问题就是动态库引用静态库引发的。**

    CocoaPods给出解决方案，在`podsepc`添加：
    ```
    # Indicates, that if use_frameworks! is specified, 
    # the pod should include a static library framework.
    s.static_framework = true
    ```
    

        
1. 编译后就可以导入百度地图的头文件了

    ```
    import UIKit
    import BaiduMapAPI_Map

    // 
    // MARK - YMHomeViewController
    public class YMHomeViewController: UIViewController, BMKGeneralDelegate {
    
    // 
    // MARK - Life Cycle
        public override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor.orange
        
            let mapManager = BMKMapManager()
            // 启动引擎并设置AK并设置delegate
            if !(mapManager.start("启动引擎失败", generalDelegate: self)) {
                print("启动引擎失败")
            }
        }
    }
    ```
    2.  这样本地工程可以正常引用百度地图SDK了，但是私有库的pod lib lint校验是无法通过的，原因是校验的时候实际是从cocopods的文件夹缓存里读取的百度sdk进行编译校验，而非通过你的本地工程已经修改的framework进行校验；处理思路，是在校验的时候找到校验路径，把本地工程生成module.modulemap拷贝到校验路径里的百度sdk目录下。重新校验，通过
