@Entry
@Component
struct ListPage {
  @State data: string[] = [];//第一个[]表示数组类型 第二个[]表示空的数组 可变长度

  // 初始值 生命周期函数 画面显示前自动调用
  aboutToAppear(): void {
    for(let i =0;i<50;i++){
      this.data.push(i+'.0721')
    }
  }
  build() {
    Column(){
      List(){
        //参数1 循环对象 参数2 循环体 e表示数组中每一个元素
        ForEach(this.data,(e:string)=>{
          ListItem(){
            Row({space:5}){
              Image($r('app.media.photo'))
                .width(24)
              Text(e)//数组元素
              //
            }
            .height(50)
            .justifyContent(FlexAlign.Start)
            .width('100%')
          }
        })


      }
      .divider({strokeWidth:1})
    }
    .padding({left:18,right:18})
    .height('100%')
    .width('100%')
  }
}