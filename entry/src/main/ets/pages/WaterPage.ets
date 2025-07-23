import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import { preferences } from '@kit.ArkData'

interface SockDevice {

  battery: string;
  rssi: string;
  updateTime: string;
  rname: string;
}

@Entry
@Component

struct SocketPage {
  @State battery: string = 'N/A';
  @State rssi: string = 'N/A';
  @State updateTime: string = 'N/A';
  @State properties: string = 'N/A';
  @State rname: string = 'N/A';

  build() {
    Column({ space: 20 }) {
      Column({ space: 20 }) {

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
          .onClick(() => {
            let url = 'http://192.168.100.1/api/room/allDevAndProcess'
            let pref = preferences.getPreferencesSync(getContext(), { name: 'zbox.xml' });
            let cookie = pref.getSync('cookie', '') as string;

            axios.post(url, null, {
              headers: {
                'Content-Type': 'application/json',
                'cookie': cookie
              },
              timeout: 1000
            })
              .then((resp: AxiosResponse) => {
                console.log(JSON.stringify(resp));
                if (resp.data.code === '0000000') {
                  const envs: SockDevice = resp.data.data.deviceInfos.envs[2];
                  this.properties = resp.data.data.deviceInfos.envs[2].properties[0].value; //这个地方记得改一下
                  this.rname = envs.rname;
                  this.battery = envs.battery;
                  this.rssi = envs.rssi;
                  this.updateTime = envs.updateTime;
                }

              })
              .catch((err: AxiosError) => {
                this.getUIContext().getPromptAction().showToast({ message: "异常" + err.message })
              })
          })
      }
      .backgroundImage($r('app.media.waterbackground')) 
      .backgroundImageSize(ImageSize.FILL)
      .expandSafeArea([SafeAreaType.SYSTEM])
      .height('100%')
      .width('100%')
    }
  }
}