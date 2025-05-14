import { YouzanSDK, YzAPiService, YzLog, LogType, putSp, getSp } from '@youzanyun/app_web/Index';
import { webview } from '@kit.ArkWeb';
import { YzDocumentVIewPicker, YzPhotoViewPicker } from '../managers/YzDocumentVIewPicker'
import { YzPermissionsManager } from '../managers/YzPermissionsManager'
import { BusinessError } from '@ohos.base';
import { promptAction, router } from '@kit.ArkUI';
import { InitStatus } from '@youzanyun/app_web/src/main/ets/model/bo/InitStatus';
import { AppStorageKey } from '@youzanyun/app_web/src/main/ets/model/constant/AppStorageKey';
import { KaeConfig } from '../KaeConfig';
import { UserInfoReqBO } from '@youzanyun/app_web/src/main/ets/model/req/request';
import { YzCookieManager } from '@youzanyun/app_web/src/main/ets/manager/YzCookieManager';
import common from '@ohos.app.ability.common';
import { MediaUtils } from '../MediaUtils';
import { checkPermission, requestPermission } from '../PermissionUtils';
import { Permissions } from '@kit.AbilityKit';
import { printAll } from '@youzanyun/app_web/src/main/ets/utils/YzPreferences';
import { ifaa } from '@kit.OnlineAuthenticationKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @StorageProp(AppStorageKey.S_KEY_INIT_STATUS) initStatus: InitStatus = InitStatus.INIT
  inputController: TextInputController = new TextInputController()
  customUrl = KaeConfig.S_URL_MAIN

  onPageShow(): void {
    YzLog.print("onPageShow")
  }

  onPageHide(): void {
    YzLog.print("onPageHide")
  }

  aboutToAppear(): void {
    YzLog.print("aboutToAppear")

    YzLog.addLog(LogType.COOKIE, `isCookieAllowed ${webview.WebCookieManager.isCookieAllowed()}`)

    // YzLog.print(`userAgent = ${new webview.WebviewController().getUserAgent()}`) // 不支持
  }

  aboutToDisappear(): void {
    YzLog.print("aboutToDisappear")
  }

  onBackPress(): boolean | void {
    YzLog.print("onBackPress")
  }


  build() {
    Stack() {
      Column() {

        this.buildTextArea()
        this.buildUrl()
        this.buildInit()
        this.buildCookie()
        this.buildApi()
        this.buildFileSelect()
        this.buildPermissions()
        this.buildMedia()
        this.buildCache()
      }
    }
  }

  @Builder
  buildUrl() {
    Row() {
      TextInput({
        placeholder: "输入url",
        text: this.customUrl,
        controller: this.inputController
      }).layoutWeight(1)
        .onChange((item) => {
          this.customUrl = item
        })
      Button("跳转", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        const url = this.customUrl.length == 0 ? KaeConfig.S_URL_MAIN : this.customUrl
        router.pushUrl({ url: 'pages/WebPage', params: { "url": url } }, (err) => {
          YzLog.print(`跳转结果：${JSON.stringify(err)}}`)
        })
      })
    }
    Row() {
      Button("跳转1", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        const url = this.customUrl.length == 0 ? KaeConfig.S_URL_MAIN : this.customUrl
        router.pushUrl({ url: 'pages/WebPage', params: { "url": KaeConfig.S_URL_MAIN1 } }, (err) => {
          YzLog.print(`跳转结果：${JSON.stringify(err)}}`)
        })
      })
    }
  }

  @Builder
  buildTextArea() {
    Column() {
      Text(`初始化结果 = ${this.initStatus} \n `)
        .width("100%")
        .padding({ top: 12, bottom: 12 })
    }.height(200)

  }

  @Builder
  buildCookie() {
    Row() {
      Button("打印cookie", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzCookieManager.checkCookie()
      })
      Button("清空", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzCookieManager.clearCookie()
      })
      Button("重置Cookie", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YouzanSDK.initCookie()
      })
    }.height(50)
  }

  @Builder
  buildMedia() {
    Row() {
      Button("权限申请", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        checkPermission(getContext() as common.UIAbilityContext, 'ohos.permission.WRITE_IMAGEVIDEO').then((data) => {
          promptAction.showToast({
            message: `权限状态 ${data}`
          })
          YzLog.print(`权限 ${data}`)
        }).catch((error: BusinessError) => {
          YzLog.print(`权限 ${error.message}`)
        })
        MediaUtils.saveToAlbum(getContext() as common.UIAbilityContext, "")
      })
      Button("保存图片", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        MediaUtils.saveToAlbum(getContext() as common.UIAbilityContext, "")
      })
    }.height(50)
  }

  @Builder
  buildApi() {
    Row() {
      Button("SDK 校验接口", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzAPiService.checkSDK()
          .then((data) => {
            promptAction.showToast({ message: "请求成功" })
          })
          .catch(() => {
            promptAction.showToast({ message: "请求失败" })
          })
      })


      Button("用户登录", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YouzanSDK.queryUserInfo(new UserInfoReqBO(
          "31467761",
          "https://cdn.daddylab.com/Upload/android/20210113/021119/au9j4d6aed5xfweg.jpeg?w=1080&h=1080",
          "一百亿养乐多",
          "0",
          ""
        ))
          .then((data) => {
            YzCookieManager.syncUserInfoCookie(data?.cookie_key ?? "", data?.cookie_value ?? "")
            YzCookieManager.checkCookie()
            promptAction.showToast({ message: "请求成功" })
          })
          .catch(() => {
            promptAction.showToast({ message: "请求失败" })
          })
      })

      Button("用户登出", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzCookieManager.clearCookie()
      })
    }
  }

  @Builder
  buildFileSelect() {
    Row() {
      Button("文件选择", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzDocumentVIewPicker.select().then((result: string[]) => {
          promptAction.showToast({ message: "选择文件成功" })
        }).catch((error: BusinessError) => {
          promptAction.showToast({ message: "选择文件失败" })
        })
      })

      Button("相册选择", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzPhotoViewPicker.select(true).then((result: string[]) => {
          promptAction.showToast({ message: `选择图片${result}` })
        }).catch((error: BusinessError) => {
          promptAction.showToast({ message: "选择文件失败" })
        })
      })
    }
  }

  @Builder
  buildPermissions() {
    Row() {
      Button("位置权限", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YzPermissionsManager.checkLocationPermission().then((ret: boolean) => {
          if (ret) {
            promptAction.showToast({ message: "已经位置授权过了" })
          } else {
            let context: Context = getContext(this) as common.UIAbilityContext;
            YzPermissionsManager.requestLocationPermission(context).then((ret: boolean) => {
              if (ret) {
                promptAction.showToast({ message: "位置授权成功" })
              } else {
                promptAction.showToast({ message: "位置授权失败" })
              }
            }).catch((err: BusinessError) => {
              promptAction.showToast({ message: "位置授权失败" })
            })
          }
        }).catch((err: BusinessError) => {
          promptAction.showToast({ message: "获取位置授权失败" })
        })
      })
    }
  }

  @Builder
  buildCache() {
    Row() {
      Button("清楚缓存", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YouzanSDK.clearCache()
      })
    }
  }

  @Builder
  buildInit() {
    Row() {
      Button("初始化", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        YouzanSDK.init(getContext() as common.UIAbilityContext, YouzanSDK.initConfig!)
      })

      Button("打印持久化数据", { type: ButtonType.Capsule }).padding(10).onClick(() => {
        printAll()
        putSp("a", `${getSp("a", 1)} 1`)
        YzLog.print(getSp("a", 1) as string)
      })
      Button("打印持久化数据1", { type: ButtonType.Capsule }).padding(10).onClick(() => {

        putSp("a", `${getSp("a", "1")} 1`)
        YzLog.print(getSp("a", 1) as string)
      })
    }
  }
}
