import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { preferences } from '@kit.ArkData'
import promptAction from '@ohos.promptAction'

interface DeviceProperty {
  value: string;
  name?: string;
  type?: string;
}

interface SockDevice {
  battery: string;
  rssi: string;
  updateTime: string;
  rname: string;
  properties?: DeviceProperty[];
}

@Entry
@Component
struct SocketPage {
  @State battery: string = 'N/A';
  @State rssi: string = 'N/A';
  @State updateTime: string = 'N/A';
  @State properties: string = 'N/A';
  @State rname: string = 'N/A';
  @State isLoading: boolean = false;
  private timerId: number = 0;

  @Builder loadingBuilder() {
    Column() {
      Progress({
        value: 0,
        total: 1,
        style: ProgressStyle.Ring
      }).width(50).height(50)
    }.margin({ top: 20 })
  }

  aboutToAppear() {
    this.fetchDeviceData();

    this.timerId = setInterval(() => {
      console.log('定时自动更新设备信息');
      this.fetchDeviceData();
    }, 10000) as number;
  }

  aboutToDisappear() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
  }

  private fetchDeviceData() {
    this.isLoading = true;
    let url = 'http://192.168.100.1/api/room/allDevAndProcess';

    try {
      let pref = preferences.getPreferencesSync(getContext(this), {
        name: 'zbox.xml'
      });
      let cookie = pref.getSync('cookie', '') as string;

      axios.post(url, null, {
        headers: {
          'Content-Type': 'application/json',
          'cookie': cookie
        },
        timeout: 3000
      })
        .then((resp: AxiosResponse) => {
          console.info('API响应数据:', JSON.stringify(resp.data));

          if (resp.data &&
            resp.data.code === '0000000' &&
          resp.data.data &&
          resp.data.data.deviceInfos &&
          resp.data.data.deviceInfos.envs &&
            resp.data.data.deviceInfos.envs.length > 2) {
            const envs = resp.data.data.deviceInfos.envs[2] as SockDevice;
            setTimeout(() => {
              this.properties = envs.properties && envs.properties[0] ?
              envs.properties[0].value : 'N/A';
              this.rname = envs.rname || 'N/A';
              this.battery = envs.battery || 'N/A';
              this.rssi = envs.rssi || 'N/A';
              //  强制时间更新
              this.updateTime = envs.updateTime ?
                envs.updateTime + ' ' : // 添加空格确保更新
              new Date().toLocaleString(); // 若无时间则使用当前时间
              this.isLoading = false;
            }, 0);

          } else {
            throw new Error('服务器返回数据格式不正确');
          }
        })
        .catch((err: Error) => {
          console.error('请求错误:', err);
          this.isLoading = false;
          this.showErrorToast(err);
        });
    } catch (e) {
      console.error('本地错误:', e);
      this.isLoading = false;
      this.showErrorToast(e as Error);
    }
  }

  private showErrorToast(err: Error) {
    let message = '请求失败: ' + err.message;
    promptAction.showToast({
      message,
      duration: 2000
    });
  }

  build() {
    Column({ space: 20 }) {
      Column({ space: 20 }) {

        if (this.isLoading) {
          this.loadingBuilder()
        }

        Column() {
          Row() {
            Image($r('app.media.water_sensor'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('标准水浸传感器')
              .fontSize(18)
          }
          .padding(10)
          .width('100%')

          Divider()
            .strokeWidth(1)
            .color(Color.Gray)

          Row() {
            Image($r('app.media.water_sensor_normal'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('状态: ' + this.properties)
              .fontSize(18)
          }
          .padding(10)
          .width('100%')

          Divider()
            .strokeWidth(1)
            .color(Color.Gray)

          Row() {
            Image($r('app.media.battery'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('电量: ' + this.battery)
              .fontSize(18)
          }
          .padding(10)
          .width('100%')

          Divider()
            .strokeWidth(1)
            .color(Color.Gray)

          Row() {
            Image($r('app.media.signal'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('信号强度: ' + this.rssi)
              .fontSize(18)
          }
          .padding(10)
          .width('100%')

          Divider()
            .strokeWidth(1)
            .color(Color.Gray)

          Row() {
            Image($r('app.media.clock'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('最新时间: ' + this.updateTime)
              .fontSize(18)
          }
          .padding(10)
          .width('100%')
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .shadow({
          radius: 8,
          color: Color.Gray,
          offsetX: 2,
          offsetY: 2
        })
        .margin({ top: 30 })

        Button('更新设备信息')
          .width('80%')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.fetchDeviceData();
          })
      }
      .backgroundImage($r("app.media.background2"))
      .backgroundImageSize(ImageSize.FILL)
      .expandSafeArea([SafeAreaType.SYSTEM])
      .height('100%')
      .width('100%')
    }
  }
}