@Entry
@Component
struct WaterSensorPage {
  @State isWaterDetected: boolean = false
  @State lastAlertTime: string = "无记录"

  build() {
    Column() {
      Image(this.isWaterDetected ? $r('app.media.water_sensor_warning') : $r('app.media.water_sensor_normal'))
        .width(120)
        .height(120)

      Text(this.isWaterDetected ? "警告：水浸！" : "状态正常")
        .fontSize(20)
        .margin({top: 15})
        .fontColor(this.isWaterDetected ? Color.Red : Color.Green)

      Text(`最后警报: ${this.lastAlertTime}`)
        .fontSize(16)
        .margin({top: 10})

      Button('模拟水浸事件')
        .margin({top: 20})
        .onClick(() => {
          this.isWaterDetected = !this.isWaterDetected
          if (this.isWaterDetected) {
            const now = new Date()
            this.lastAlertTime = `${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}