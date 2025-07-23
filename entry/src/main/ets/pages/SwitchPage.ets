@Entry
@Component
struct SwitchPage {
  @State img: string = 'app.media.socket_switch_off';
  @State powerConsumption: number = 0; // 当前功耗（瓦特）
  @State totalEnergy: number = 0;     // 总耗电量（瓦时）
  private timer: number = 0;          // 定时器ID
  build() {

  }
  // 新增代码开始 - 添加HTTP请求能力
  @State isRequesting: boolean = false; // 防止重复点击
  private ieee: string = '1c1cfd001dba1a63'; // 插座IEEE地址
  private apiUrl: string = 'http://192.168.100.1/api/terminal/zigbee/sock/ctrl';
/*
  // 封装HTTP请求
  private async httpRequest(data: object): Promise<any> {
    try {
      let httpRequest = await import('@ohos.net.http');
      let http = httpRequest.createHttp();

      let response = await http.request(
        this.apiUrl,
        {
          method: 'POST',
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(data)
        }
      );

      if (response.responseCode === 200) {
        return JSON.parse(response.result);
      } else {
        throw new Error(`HTTP错误: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('请求失败:', error);
      throw error;
    }
  }

  // 控制插座方法
  private async controlSocket(status: number) {
    if (this.isRequesting) return;
    this.isRequesting = true;

    try {
      let result = await this.httpRequest({
        ieee: this.ieee,
        status: status
      });

      if (result.code !== '0000000') {
        throw new Error(result.error || '控制失败');
      }
    } catch (error) {
      console.error('插座控制失败:', error);
      // 恢复之前的状态
      this.img = status === 1 ? 'app.media.socket_switch_off' : 'app.media.socket_switch_on';
      // 这里可以添加提示Toast，需要导入@ohos.promptAction
      promptAction.showToast({
        message: '控制失败: ' + error.message,
        duration: 2000
      });
    } finally {
      this.isRequesting = false;
    }
  }
  // 新增代码结束

  // 模拟功耗变化
  private simulatePowerChange() {
    // 如果开关是打开状态，则模拟功耗变化
    if (this.img == 'app.media.socket_switch_on') {
      // 随机生成一个介于5-150之间的功耗值
      this.powerConsumption = Math.floor(Math.random() * 145) + 5;
      // 累计总耗电量（假设每5秒记录一次）
      this.totalEnergy += this.powerConsumption * (5 / 3600);
    } else {
      this.powerConsumption = 0;
    }
  }

  aboutToAppear() {
    // 启动定时器，每5秒更新一次功耗数据
    this.timer = setInterval(() => {
      this.simulatePowerChange();
    }, 5000);
  }

  aboutToDisappear() {
    // 清除定时器
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  build() {
    RelativeContainer() {
      Column({ space: 10 }) {
        Image($r(this.img))
          .width(200)


        if (this.img == 'app.media.socket_switch_off') {
          Text('关')
            .fontSize(30)
            .fontColor(Color.Red)
        } else {
          Text('开')
            .fontSize(30)
            .fontColor(Color.Green)
        }


        Row() {
          Text('当前功率:')
            .fontSize(18)
            .fontColor(Color.Black)
          Text(`${this.powerConsumption.toFixed(1)} W`)
            .fontSize(18)
            .fontColor(this.powerConsumption > 100 ? Color.Red : Color.Blue)
        }
        .margin({ top: 20 })

        Row() {
          Text('累计耗电:')
            .fontSize(18)
            .fontColor(Color.Black)
          Text(`${this.totalEnergy.toFixed(2)} Wh`)
            .fontSize(18)
            .fontColor(Color.Blue)
        }
        .margin({ top: 10 })

      }
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .onClick(() => {
        if (this.img == 'app.media.socket_switch_off') {
          this.img = 'app.media.socket_switch_on';
          // 新增代码 - 调用打开接口
          this.controlSocket(1);
        } else {
          this.img = 'app.media.socket_switch_off';
          // 新增代码 - 调用关闭接口
          this.controlSocket(0);
        }
        // 切换开关状态时立即更新功耗
        this.simulatePowerChange();
      })
    }
    .backgroundColor(this.img == 'app.media.socket_switch_off' ? Color.Gray : Color.White)
    .height('100%')
    .width('100%')
  }
}
*/}