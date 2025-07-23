import { preferences } from '@kit.ArkData';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@ohos.base';
import { ComponentContent } from '@kit.ArkUI';

interface Device {
  rname: string;
  deviceName: string;
  out_of_date: boolean;
  id: string;
  ieee: string;
  shortIeee: string;
  roomid: string;
  terminalDefId: string;
  description: string;
  battery: string;
  rssi: string;
  updateTime: string;
  valid: string;
  cid: string;
  parentInfo: ParentInfo;
  maintype: string;
  subtype: string;
  status?: string; // 仅socks有该字段
  power?: string;  // 仅socks有该字段
  properties?: DeviceProperty[]; // 仅envs有该字段
  devOrder: string;
  devCommonOrder: string;
}
interface ParentInfo {
  type: string;
  ieee: string;
  dispName: string;
}
interface DeviceProperty {
  name: string;
  id: string;
  value: string;
  display_index: string;
  update_datetime: string;
  keyValue?: string; // 可选字段（部分属性有该字段）
}
interface DeviceWithType {
  device: Device;
  type: string; // 'socks' | 'envs'
}
interface DeviceInfos {
  socks?: Device[];
  envs?: Device[];
}

class Params {
  refreshStatus: RefreshStatus = RefreshStatus.Inactive;

  constructor(refreshStatus: RefreshStatus) {
    this.refreshStatus = refreshStatus;
  }
}
@Builder
function customRefreshingContent(params: Params): void {
  // 使用 params.refreshStatus 控制样式等
  Stack() {
    Row() {
      LoadingProgress().height(32)
    }
    .alignItems(VerticalAlign.Center)
  }
  .align(Alignment.Center)
  .constraintSize({ minHeight: 32 })
  .width("100%")
}

@Entry
@Component

struct MainPage {
  @State isRefreshing: boolean = false;
  @State maxRefreshingHeight: number = 100.0;
  @State ratio: number = 1;
  @State deviceList: DeviceWithType[] = [];
  private async fetchAndSaveDevices(): Promise<void> {
    const url = 'http://192.168.100.1/api/room/allDevAndProcess';
    try {
      const pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
      const cookie = pref.getSync('cookie', '') as string;
      const resp: AxiosResponse = await axios.post(url, null, {
        timeout: 1000,
        headers: {
          'Content-Type': 'application/json',
          'cookie': cookie
        }
      });
      if (resp.data?.data?.deviceInfos) {
        const rawData: DeviceInfos = resp.data.data.deviceInfos;

        // 合并并显式标注类型
        const mergedDevices: DeviceWithType[] = [];

        if (rawData.socks) {
          (rawData.socks as Device[]).forEach((dev: Device) => {
            mergedDevices.push({ device: dev, type: 'socks' });
          });
        }

        if (rawData.envs) {
          (rawData.envs as Device[]).forEach((dev: Device) => {
            mergedDevices.push({ device: dev, type: 'envs' });
          });
        }

        this.deviceList = mergedDevices;
        await this.saveToPreferences(mergedDevices);

        this.getUIContext().getPromptAction().showToast({ message: '设备信息获取并保存成功' });
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '设备数据格式错误' });
      }
    } catch (err) {
      if (err instanceof AxiosError) {
        console.error(`请求失败: ${err.message}`);
        this.getUIContext().getPromptAction().showToast({ message: `请求失败: ${err.message}` });
      } else {
        const error = err as BusinessError;
        console.error(`操作失败: ${error.code} - ${error.message}`);
        this.getUIContext().getPromptAction().showToast({ message: '设备信息处理失败' });
      }
    }
  }
  private async saveToPreferences(deviceInfos: DeviceWithType[]): Promise<void>{}
  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      duration: 2000
    });
  }
  private getDeviceIcon(type: string): Resource {
    switch (type) {
      case 'sos':
        return $r('app.media.icon_main_net_a');
      case 'hd': // 人体活动
        return $r('app.media.icon_main_cloud_a');
      case 'water':
        return $r('app.media.icon_main_download_a');
      case 'temperature_humidity':
        return $r('app.media.icon_main_data_a');
      case 'magnetic':
        return $r('app.media.icon_main_scene_a');
      case 'outlet':
        return $r('app.media.icon_main_photo_a');
      default:
        return $r('app.media.icon_main_photo_a');
    }
  }
  private getDeviceUrl(type: string): string {
    switch (type) {
      case 'sos':
        return 'pages/SOSPage';
      case 'hd': // 人体活动
        return 'pages/MSPage';
      case 'water':
        return 'pages/NetPage';
      case 'temperature_humidity':
        return 'pages/NetPage';
      case 'magnetic':
        return 'pages/DoorPage';
      case 'outlet':
        return 'pages/SwitchPage';
      default :
        return 'pages/DefaultPage'
    }
  }
  private contentNode?: ComponentContent<Object> = undefined;
  private params: Params = new Params(RefreshStatus.Inactive);
  aboutToAppear(): void {
    let uiContext = this.getUIContext();
    this.params = new Params(RefreshStatus.Inactive);
    this.contentNode = new ComponentContent(uiContext, wrapBuilder(customRefreshingContent), this.params);
  }

  build() {

    Tabs({barPosition:BarPosition.End}){
      TabContent(){
        Column(){
          Refresh({
            refreshing: this.isRefreshing,
            refreshingContent: this.contentNode
          })
            .onStateChange((status: RefreshStatus) => {
              if (status === RefreshStatus.Refresh) {
                this.isRefreshing = true;
                this.fetchAndSaveDevices().then(() => {
                  this.isRefreshing = false;
                });
              }
            })
          Grid() {
            ForEach(this.deviceList, (item: DeviceWithType, index: number) => {
              GridItem() {
                Column({ space: 5 }) {
                  Image(this.getDeviceIcon(item.device.maintype))
                    .width(72)
                  Text(item.device.rname)
                }
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({ url: this.getDeviceUrl(item.device.maintype) });
                })
              }
            })

          }
          .height('100%')
          .width('100%')
          .padding({ left: 18, right: 18 }) // 内边距
          .columnsTemplate('1fr 1fr')       // 两列
          .columnsGap(20)                   // 列间距
          .rowsGap(10)                      // 行间距
          .gesture(
            LongPressGesture({
              repeat: false,
              duration: 800
          })
              .onAction(()=>{

              })
          )
        }
      }
      .tabBar('设备')

      TabContent(){
        Text('各个房间').fontSize(20)
      }
      .tabBar('房间')

      TabContent(){
        Text('扩展内容').fontSize(20)
      }
      .tabBar('发现')

      TabContent(){
        Text('各个场景').fontSize(20)
      }
      .tabBar('场景')

      TabContent(){

      }
      .tabBar('我的')
    }
  }

}