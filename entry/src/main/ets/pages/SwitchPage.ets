import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { preferences } from '@kit.ArkData';

// 接口定义保持不变
interface RequestParams {
  ieee: string;
  shortAddr: string;
}

interface DeviceInfo {
  socks: SockDevice[];
}

interface ResponseData {
  deviceInfos: DeviceInfo;
}

interface ApiResponse {
  code: string;
  data: ResponseData;
}

interface DeviceIdentifier {
  ieee: string;
  shortAddr: string;
}

interface ControlSocketRequest {
  status: 'ON' | 'OFF';
  ieee: string;
  shortAddr: string;
}

interface SockDevice {
  status: string;
  power: string;
  ieee: string;
  shortAddr: string;
}

@Entry
@Component
struct SwitchPage {
  @State img: Resource = $r('app.media.socket_switch_off');
  @State powerConsumption: number = 0;
  @State isOn: boolean = false;

  // +++ 明确初始化设备信息（实际连接的目标设备）
  private readonly deviceInfo: DeviceIdentifier = {
    ieee: '1c1cfd001dba1a63',  // 目标设备IEEE
    shortAddr: '3f15'           // 目标设备短地址
  };

  private updateSocketState(newStatus: boolean) {
    this.isOn = newStatus;
    this.img = newStatus ? $r('app.media.socket_switch_on') : $r('app.media.socket_switch_off');
    this.powerConsumption = newStatus ? 220 : 0;
  }

  private fetchDeviceData() {
    let url = 'http://192.168.100.1/api/terminal/zigbee/sock/ctrl';
    let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
    let cookie = pref.getSync('cookie', '') as string;

    // +++ 确保请求参数使用当前设备信息
    const params: RequestParams = {
      ieee: this.deviceInfo.ieee,
      shortAddr: this.deviceInfo.shortAddr
    };

    axios.get<ApiResponse>(url, {
      params: params,
      headers: {
        'Content-Type': 'application/json',
        'cookie': cookie
      },
      timeout: 1000
    })
      .then((resp: AxiosResponse<ApiResponse>) => {
        if (resp.data.code === '0000000') {
          const devices = resp.data.data.deviceInfos.socks;
          // +++ 精确匹配目标设备
          const targetDevice = devices.find((d: SockDevice) =>
          d.ieee === this.deviceInfo.ieee &&
            d.shortAddr === this.deviceInfo.shortAddr);

          if (targetDevice) {
            this.updateSocketState(targetDevice.status === 'ON');
          }
        }
      })
      .catch((err: AxiosError) => {
        console.error("状态获取失败:", err.message);
      });
  }

  private toggleSocket() {
    const newStatus = !this.isOn;
    this.updateSocketState(newStatus);

    // +++ 控制请求使用当前设备信息
    const requestData: ControlSocketRequest = {
      status: newStatus ? 'ON' : 'OFF',
      ieee: this.deviceInfo.ieee,
      shortAddr: this.deviceInfo.shortAddr
    };

    let url = 'http://192.168.100.1/api/terminal/zigbee/sock/ctrl';
    let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
    let cookie = pref.getSync('cookie', '') as string;

    axios.post(url, requestData, {
      headers: {
        'Content-Type': 'application/json',
        'cookie': cookie
      },
      timeout: 1000
    }).catch((err: AxiosError) => {
      this.updateSocketState(!newStatus);
      console.error("状态切换失败:", err.message);
      this.getUIContext().getPromptAction().showToast({
        message: "控制失败: " + err.message
      });
    });
  }

  build() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Column({ space: 10 }) {
        Image(this.img)
          .width(200)
          .onClick(() => this.toggleSocket())

        Text(this.isOn ? '开' : '关')
          .fontSize(30)
          .fontColor(this.isOn ? Color.Green : Color.Red)

        Column() {
          Text(`IEEE: ${this.deviceInfo.ieee}`)
            .fontSize(14)
            .fontColor(Color.Blue)
          Text(`短地址: ${this.deviceInfo.shortAddr}`)
            .fontSize(14)
            .fontColor(Color.Blue)
        }
        .margin({ top: 10 })

        Button('刷新状态')
          .width('60%')
          .margin({ top: 20 })
          .onClick(() => this.fetchDeviceData())

        Row() {
          Text('当前功率:')
            .fontSize(18)
            .fontColor(Color.Black)
          Text(`${this.powerConsumption} W`)
            .fontSize(18)
            .fontColor(this.isOn ? Color.Red : Color.Blue)
        }
        .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isOn ? 0xFFFFFF : 0xEAEAEA)
  }

  aboutToAppear() {
    this.fetchDeviceData();
  }
}