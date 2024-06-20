import { YzLog, YzWeb } from '@youzan/app_web/Index';
import { promptAction, router } from '@kit.ArkUI';
import { YzWebEventClient } from '@youzan/app_web/src/main/ets/components/YzWebEventClient';
import { YzCookieManager } from '@youzan/app_web/src/main/ets/manager/YzCookieManager';
import {
  print_READY,
  print_window,
  share,
  trigger_web_ready
} from '@youzan/app_web/src/main/ets/model/constant/YzConstant';
import { BusinessError } from '@kit.BasicServicesKit';
import { YzDocumentVIewPicker, YzPhotoViewPicker } from '../managers/YzDocumentVIewPicker'
import { MyWebviewController } from '../controller/MyWebviewController'

import { webview } from '@kit.ArkWeb';
import { picker } from '@kit.CoreFileKit';
import { YzWebviewController } from '@youzan/app_web/src/main/ets/components/YzWebviewController';
import { checkPermission } from '../PermissionUtils';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { MediaUtils } from '../MediaUtils';

interface UrlParams {
  url: string
}

let para: Record<string, string> = { 'title': "222" };
let storage: LocalStorage = new LocalStorage(para);


class MyWebDelegate extends YzWebEventClient {
  onTitleReceive(title: string): void {
    storage.setOrCreate("title", title)
  }

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
    let isSelectPicture = fileSelector?.getAcceptType().indexOf(".jpg") != -1
    // if (isSelectPicture) {
    YzPhotoViewPicker.select(isSelectPicture).then((list: string[]) => {
      promptAction.showToast({ message: "选择图片成功" })
      result?.handleFileList(list)
    }).catch((error: BusinessError) => {
      promptAction.showToast({ message: "选择图片失败" })
    })
    // } else {
    //   YzDocumentVIewPicker.select().then((result: string[]) => {
    //     promptAction.showToast({ message: "选择文件成功" })
    //     // result.handleFileList(result)
    //   }).catch((error: BusinessError) => {
    //     promptAction.showToast({ message: "选择文件失败" })
    //   })
    // }
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


@Entry(storage)
@Component
struct WebPage {
  @State url: string = '';
  @State delegate: MyWebDelegate = new MyWebDelegate()
  @State controller: MyWebviewController = new MyWebviewController()
  @LocalStorageProp('title') title: string = "1111";

  onPageShow(): void {
    YzLog.print("onPageShow")
    YzCookieManager.checkCookie()
  }

  onPageHide(): void {
    YzLog.print("onPageHide")
  }

  aboutToAppear(): void {
    const params: UrlParams = router.getParams() as UrlParams
    this.url = params.url
    YzLog.print("aboutToAppear")
    YzLog.print(`读取参数url = ${params.url}`)
    this.controller.registerYZJSSubscribers()
  }

  aboutToDisappear(): void {
    YzLog.print("aboutToDisappear")
    YzCookieManager.clearCookie()
  }

  onBackPress(): boolean | void {
    YzLog.print("onBackPress")
    if (this.delegate.controller?.accessBackward() && this.delegate.controller?.goBack()) {
      return true
    }
  }

  @Builder
  buildNarBar() {
    Row() {
      MyButton()
      Button("关闭").onClick(() => {
        router.back()
      })
      Button("返回").onClick(() => {

        if (!this.delegate.controller?.goBack()) {
          router.back()
        }

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

      Text(`${this.title}`)
    }
  }

  build() {
    Column() {
      // Stack({ alignContent: Alignment.Top }) {
      this.buildNarBar()
      YzWeb({
        url: this.url,
        delegate: this.delegate,
        controller: this.controller
      }).layoutWeight(1)
      // }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct MyButton {
  @Prop a: string | undefined | null = null
  @Prop b: string

  build() {
    Row()
  }
}