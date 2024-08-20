

## 安装
`ohpm install @youzanyun/app_web`

## SDK初始化
在加载有赞页面之前对SDK进行初始化，比如：在`EntryAbility`的`onCreate`方法中，示例如下:
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
需要传入一个UIAbilityContext和InitConfig实例，InitConfig实例可以配置clientId、clientKey等等，具体参数说明如下：
- `debug`：是否开启debug模式
- `clientId`：您申请的clientId
- `clientKey`：您申请的clientKey
- `logConfig`：日志相关的配置，可以配置`support`参数，确定是否开启日志打印
- `webConfig`：web相关的配置，可以配置`supportLongPress`参数，确定是否支持长按保存图片

## web组件接入
web组件主要依赖三个参数：
- `url`：需要加载的web地址
- `delegate`：继承于`YzWebEventClient`的实例，`YzWeb`基于系统`Web`组件，系统Web组件所有的事件通过`delegate`分发出来，供业务方使用
- `controller`：继承于`YzWebviewController`的实例，`YzWebviewController`继承于系统的`WebviewController`，封装了涉及有赞的跳转、js bridge注册、url返回等方法

### 实现WebviewController
自定义`WebviewController`，需继承`YzWebviewController`，`YzWebviewController`是继承了鸿蒙 `webview.WebviewController`，封装了涉及有赞的跳转、js bridge注册、url返回等方法

通过`registerJSSubscriber`方法订阅有赞的JS事件，具体事件Key对应事件说明如下：

| 事件Key                             | 说明                    |
|-----------------------------------|-----------------------|
| KEY_AUTHENTICATION                | 获取用户信息                |
| KEY_PAGE_READY                    | Web页面已准备好，分享接口可用      |
| KEY_SHARE                         | 分享事件                  |
| KEY_FILE_CHOOSER                  | 文件选择事件                |
| KEY_CUSTOM_ACTION                 | 通用自定义事件               |
| KEY_ADD_TO_CART                   | 用户添加商品到购物车            |
| KEY_BUY_NOW                       | 商品详情页点击“立即购买”         |
| KEY_ADD_UP                        | 购物车页面点击“结算”时回调        |
| KEY_PAYMENT_FINISHED              | 支付完成回到结果页，结果页收到支付成功回调 |
| KEY_CHECK_AUTH_MOBILE             | 登陆完成后的回调              |
| KEY_AUTHORIZATION_SUCCESS         | 一键登录成功回调              |
| KEY_AUTHORIZATION_ERROR           | 一键登录失败回调              |
| KEY_INVOKE_DISAGREE_PROTOCOL      | 不同意协议并退出              |
| KEY_INVOKE_GO_CASHIER             | 拉起三方收银台               |
| KEY_INVOKE_CANCEL_ACCOUNT_SUCCESS | 账号注销成功回调              |
| KEY_INVOKE_CANCEL_ACCOUNT_FAIL    | 账号注销失败回调              |
| KEY_INVOKE_CHANGE_PULL_REFRESH    | 当前页面下拉刷新功能开关          |

根据业务方具体需求，按需订阅，示例如下:
```typescript
import { JsSubscribeKey } from '@youzanyun/app_web/src/main/ets/model/constant/JsDefine';
import { YzWebviewController } from '@youzanyun/app_web/src/main/ets/components/YzWebviewController';
import { UserInfoReqBO } from '@youzanyun/app_web/src/main/ets/model/req/request';
import { YouzanSDK } from '@youzanyun/app_web';

export class MyWebviewController extends YzWebviewController {
  private doJsEvent(key: string, params: string) {
    switch (key) {
      case JsSubscribeKey.KEY_AUTHENTICATION: { // 用户登录
        YouzanSDK.queryUserInfo(new UserInfoReqBO(
          "31467761", // 有赞openId 必传 开发者自身系统的用户ID，是三方App帐号在有赞的唯一标示符，如更换将导致原用户数据丢失
          "https://cdn.daddylab.com/Upload/android/20210113/021119/au9j4d6aed5xfweg.jpeg?w=1080&h=1080", // 头像信息
          "一百亿养乐多", // 非必传，用户头像，建议传入https的url
          "0",    // 非必传，性别 0（保密）1（男）2（女）
          "" // 非必传，用户额外参数
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

### 实现WebEventClient
自定义`WebEventClient`，需继承于`YzWebEventClient`。因为鸿蒙组件不支持继承，Web组件的事件通过`WebEventClient`分发到业务层，`WebEventClient`中的事件基本都是透传Web组件原生的事件，具体事件可以参考Web组件的事件。
```typescript
import { YzLog, YzWeb } from '@youzanyun/app_web/Index';
import { YzWebEventClient } from '@youzanyun/app_web/src/main/ets/components/YzWebEventClient';
import { YzCookieManager } from '@youzanyun/app_web/src/main/ets/manager/YzCookieManager';
import {
  share,
} from '@youzanyun/app_web/src/main/ets/model/constant/YzConstant';


import { MediaUtils } from '../MediaUtils';
import { YzDocumentVIewPicker, YzPhotoViewPicker } from '../managers/YzDocumentVIewPicker'
import { MyWebviewController } from '../controller/MyWebviewController'
import { checkPermission } from '../PermissionUtils';


class MyWebDelegate extends YzWebEventClient {
  // "页面开始加载
  onPageBegin(url: string): void {
    // promptAction.showToast({ message: "页面开始加载" + url })
  }
  
  //  页面结束加载
  onPageEnd(url: string): void {
    // promptAction.showToast({ message: "页面结束加载" + url })
  }
  
  // 上传文件。处理前端页面文件上传的请求
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

  // 长按图片后，点击保存图片回调
  onImageSave(url: string): boolean {
    // getContext 是系统方法 
    checkPermission(getContext() as common.UIAbilityContext, 'ohos.permission.WRITE_IMAGEVIDEO').then((data) => {
      if (data == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        MediaUtils.saveToAlbum(getContext() as common.UIAbilityContext, url)
      }
    })
    return true
  }
}

```
### 使用示例
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
  
  build() {
    Column() {
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
