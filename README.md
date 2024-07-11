
## 接入
```
  ohpm i @youzanyun/app_web
```
## 初始化
```typescript
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    YouzanSDK.init(this.context, new InitConfig(
      false,
      "申请的clientid",
      "申请的clientKey",
      {
        support: true
      },
      {
        supportLoading: true,
        supportLongPress: true
      }))
  }
}
```


## web组件接入
### 继承YzWebviewController
- YzWebviewController是继承了鸿蒙 webview.WebviewController， 封装了涉及有赞的跳转、js bridge注册、url返回等方法
```typescript
export class MyWebviewController extends YzWebviewController {
  private doJsEvent(key: string, params: string) {
    switch (key) {
      case JsSubscribeKey.KEY_AUTHENTICATION: { // 用户登录
        YouzanSDK.queryUserInfo(new UserInfoReqBO(
          "31467761",
          "https://cdn.daddylab.com/Upload/android/20210113/021119/au9j4d6aed5xfweg.jpeg?w=1080&h=1080",
          "一百亿养乐多",
          "0",
          ""
        ))
          .then((data) => {
            setTimeout(() => {
              this.refresh()
            }, 500)
            promptAction.showToast({ message: "请求成功" })
          })
          .catch(() => {
            promptAction.showToast({ message: "请求失败" })
          })
        break
      }
      default: {
        break
      }
    }
  }

  //------------------- YZJs subscribe
  registerYZJSSubscribers() {
    const eventKeys = [
      JsSubscribeKey.KEY_AUTHENTICATION,
      JsSubscribeKey.KEY_PAGE_READY,
      JsSubscribeKey.KEY_SHARE,
      JsSubscribeKey.KEY_FILE_CHOOSER,
      JsSubscribeKey.KEY_CUSTOM_ACTION,
      JsSubscribeKey.KEY_ADD_TO_CART,
      JsSubscribeKey.KEY_BUY_NOW,
      JsSubscribeKey.KEY_WX_PAY,
      JsSubscribeKey.KEY_ADD_UP,
      JsSubscribeKey.KEY_PAYMENT_FINISHED,
      JsSubscribeKey.KEY_CHECK_AUTH_MOBILE,
      JsSubscribeKey.KEY_AUTHORIZATION_SUCCESS,
      JsSubscribeKey.KEY_AUTHORIZATION_ERROR,
      JsSubscribeKey.KEY_INVOKE_DISAGREE_PROTOCOL,
      JsSubscribeKey.KEY_INVOKE_GO_CASHIER,
      JsSubscribeKey.KEY_INVOKE_CANCEL_ACCOUNT_SUCCESS,
      JsSubscribeKey.KEY_INVOKE_CANCEL_ACCOUNT_FAIL,
      JsSubscribeKey.KEY_INVOKE_CHANGE_PULL_REFRESH,
    ]
    eventKeys.forEach((item) => {
      this.registerJSSubscriber({
        "key": item,
        "onCall": (key: string, params: string) => {
          this.doJsEvent(key, params)
        }
      })
    })
  }
}
``` 


### 继承YzWebEventClient
 - 由于鸿蒙组件不支持继承， web组件的事件通过YzWebEventClient分发到业务层
```typescript
    class MyWebDelegate extends YzWebEventClient {
  onPageBegin(url: string): void {
    // promptAction.showToast({ message: "页面开始加载" + url })
  }

  onPageEnd(url: string): void {
    // promptAction.showToast({ message: "页面结束加载" + url })
  }

  onShowFileSelector(
    result: FileSelectorResult | undefined,
    fileSelector: FileSelectorParam | undefined
  ): boolean {
    let isSelectPicture = false
    if (isSelectPicture) {
      YzPhotoViewPicker.select().then((result: string[]) => {
        promptAction.showToast({ message: "选择图片成功" })
        // result.handleFileList(result)
      }).catch((error: BusinessError) => {
        promptAction.showToast({ message: "选择图片失败" })
      })
    } else {
      YzDocumentVIewPicker.select().then((result: string[]) => {
        promptAction.showToast({ message: "选择文件成功" })
        // result.handleFileList(result)
      }).catch((error: BusinessError) => {
        promptAction.showToast({ message: "选择文件失败" })
      })
    }
    return true;
  }

  onImageSave(url: string): boolean {
    checkPermission(getContext() as common.UIAbilityContext, 'ohos.permission.WRITE_IMAGEVIDEO').then((data) => {
      if (data == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        MediaUtils.saveToAlbum(getContext() as common.UIAbilityContext, url)
      }
    })
    return true
  }
}

```
### 使用
```ets
@Entry
@Component
struct WebPage {
  @State url: string = '';
  @State delegate: MyWebDelegate = new MyWebDelegate()
  @State controller: MyWebviewController = new MyWebviewController()
  
   onBackPress(): boolean | void {
    YzLog.print("onBackPress")
    if (this.delegate.controller?.accessBackward() && this.delegate.controller?.goBack()) {
      return true
    }
  }
  
    @Builder
  buildTitle() {
    Row() {
      Button("返回").onClick(() => {

        this.delegate.controller?.goBack()

        // this.delegate.controller?.runJavaScript(print_window)
      })

      Button("分享").onClick(() => {
        this.delegate.controller?.runJavaScript(share).then(() => {
          YzLog.print(`run js 成功`)
        }).catch((err: BusinessError) => {
          YzLog.print(`run js 失败 ${err.message}}`)
        })


      })

      Button("重新加载").onClick(() => {
        this.controller.refresh()
      })
    }
  }
  
  
  build() {
    Column() {
      this.buildTitle()
      YzWeb({
        url: this.url,
        delegate: this.delegate,
        controller: this.controller
      })
    }
    .width('100%')
  }
  
}
```

# License
```
The MIT License (MIT)
Copyright © 2024 Youzan

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
