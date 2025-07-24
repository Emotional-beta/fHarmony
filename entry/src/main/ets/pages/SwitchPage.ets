import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { preferences } from '@kit.ArkData'

interface SockDevice {
  status: string;
  power: string;
  battery: string;
  rssi: string;
  updateTime: string;
}

@Entry
@Component

struct SocketPage {
  @State status: string = 'N/A';
  @State power: string = 'N/A';
  @State battery	: string = 'N/A';
  @State rssi: string = 'N/A';
  @State updateTime: string = 'N/A';


  build() {
    Column({ space: 20 }) {
      Column({ space: 20 }) {
        // 白色卡片容器
        Column() {
          // 设备名称行
          Row() {
            Image($r('app.media.socket_switch'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('智能插座' )
              .fontSize(18)
          }
          .padding(10)
          .width('100%')

          // 灰色分割线
          Divider()
            .strokeWidth(1)
            .color(Color.Gray)
          //.margin({ vertical: 5 })

          // 状态行
          Row() {
            Image($r('app.media.socket_switch_on'))
              .width(24)
              .height(24)
              .margin({ right: 12 })
            Text('插座开关状态: ' + this.status)
              .fontSize(18)
          }
          .padding(10)
          .width('100%')
          
          Divider()
            .strokeWidth(1)
            .color(Color.Gray)
          //.margin({ vertical: 5 })


          // 电量行
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
          //.margin({ vertical: 5 })

          // 信号强度行
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
          //.margin({ vertical: 5 })

          // 更新时间行
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
          .onClick(() => {
            let url = 'http://192.168.100.1/api/room/allDevAndProcess'
            let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
            let cookie = pref.getSync('cookie', '') as string;
            // 参数2,没有,所有设备信息, 有, ieee
            axios.post(url, null, {
              headers: {
                'Content-Type': 'application/json',
                'cookie': cookie // 登陆状态保持
              },
              timeout: 1000
            })
              .then((resp: AxiosResponse) => {
                console.log(JSON.stringify(resp));
                if (resp.data.code === '0000000') {
                  const socks : SockDevice  = resp.data.data.deviceInfos.socks[0];
                  this.status = socks.status;
                  this.power = socks.power;
                  this.battery = socks.battery;
                  this.rssi = socks.rssi;
                  this.updateTime = socks.updateTime;
                }

              })
              .catch((err: AxiosError) => {
                this.getUIContext().getPromptAction().showToast({ message: "异常" + err.message })
              })
          })
      }
      .backgroundImage($r('app.media.background2'))
      .backgroundImageSize(ImageSize.FILL)  
      .expandSafeArea([SafeAreaType.SYSTEM])
      .height('100%')
      .width('100%')
    }
  }}