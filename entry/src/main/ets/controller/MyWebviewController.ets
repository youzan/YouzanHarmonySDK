import { JsSubscribeKey } from '@youzan/app_web/src/main/ets/model/constant/JsDefine'
import { YzWebviewController } from '@youzan/app_web/src/main/ets/components/YzWebviewController'
import { YouzanSDK } from '@youzan/app_web/Index';
import { promptAction } from '@kit.ArkUI';
import { UserInfoReqBO } from '@youzan/app_web/src/main/ets/model/req/request';
import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';

export class MyWebviewController extends YzWebviewController {
  private doJsEvent(key: string, params: string) {
    switch (key) {
      case JsSubscribeKey.KEY_FILE_CHOOSER: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_CUSTOM_ACTION: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_ADD_TO_CART: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_BUY_NOW: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_WX_PAY: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_ADD_UP: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_PAYMENT_FINISHED: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_CHECK_AUTH_MOBILE: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_AUTHORIZATION_SUCCESS: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_AUTHORIZATION_ERROR: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_INVOKE_DISAGREE_PROTOCOL: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_INVOKE_GO_CASHIER: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_INVOKE_CANCEL_ACCOUNT_SUCCESS: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_INVOKE_CANCEL_ACCOUNT_FAIL: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_INVOKE_CHANGE_PULL_REFRESH: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_AUTHENTICATION: {
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
      case JsSubscribeKey.KEY_PAGE_READY: {
        // todo
        break
      }
      case JsSubscribeKey.KEY_SHARE: {
        const paramsData: ESObject = JSON.parse(params);
        const title: string = paramsData['title']
        const link: string = paramsData['link']
        const desc: string = paramsData['desc']
        let data: systemShare.SharedData = new systemShare.SharedData({
          utd: utd.UniformDataType.HYPERLINK,
          title: title,
          content: link,
          description: desc
        });
        let controller: systemShare.ShareController = new systemShare.ShareController(data);
        let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        controller.on('dismiss', () => {
          // 分享结束，可处理其他业务。
        });
        controller.show(context, {
          previewMode: systemShare.SharePreviewMode.DETAIL,
          selectionMode: systemShare.SelectionMode.SINGLE
        });
        break
      }
      default: {
        break
      }
    }
  }

  // js subscribe
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