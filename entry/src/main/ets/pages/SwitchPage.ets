@Entry
@Component
struct SwitchPage {
  @State img:string='app.media.icon_switch_off1'

  build() {
    RelativeContainer() { //相对布局
     Column({ space: 50 }){
       Image($r(this.img))
         .width(200)
       if (this.img=='app.media.icon_switch_off1'){
         Text('关闭状态')
           .fontSize('24')
           .fontColor(Color.Red)
       }else{
         Text('开启状态')
           .fontSize('24')
           .fontColor(Color.Green)
       }
     }.alignRules({
       center: { anchor: '__container__', align: VerticalAlign.Center },
       middle: { anchor: '__container__', align: HorizontalAlign.Center }
     })
     .onClick(() => {
       if(this.img != 'app.media.icon_switch_on1') this.img = 'app.media.icon_switch_on1';
       else this.img = 'app.media.icon_switch_off1';
     })
    }
    .backgroundColor(this.img =='app.media.icon_switch_off1'?Color.Gray:Color.White)
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM])
  }
}