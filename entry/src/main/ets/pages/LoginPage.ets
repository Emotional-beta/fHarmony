
import axios, { AxiosError, AxiosResponse, AxiosResponseTransformer } from '@ohos/axios';
import CryptoJS from '@ohos/crypto-js'
import { preferences } from '@kit.ArkData';
interface LoginUser {
  username:string,
  password:string
}@Entry
@Component
struct LoginPage {
  //普通变量，如果变量值改变，不会自动更新UI；UI组件导致值的更新，不会同步到普通变量
  //名称:类型=初始值;
  //@state 状态变量 如果状态值改变会自动刷新UI
  //$$变量名 UI组件导致值的更新，会同步到普通变量

  @State username:string='';
  @State password:string='';
  @State agree:boolean=false;
  is_password_correct:string='';

  build() {
   //线性布局
    //Row():主轴是行;Column():主轴是列
    Column({space:20}){//创建主轴为列对象 {}内放键值对的方式传参
      Image($r('app.media.photo'))//引用资源 $r
        .width(120)
        .margin({top:150})//外边距

      TextInput({placeholder:'用户名',text:$$this.username})//默认值：text:‘内容’
        .width('61.8%')


      TextInput({placeholder:'密码',text:$$this.password})//默认值：text:‘内容’
        .width('61.8%')
        .type(InputType.Password)

      Row({space:5}){
        Checkbox()
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .select($$this.agree)
        Text('请同意《信息安全协议》')
          .onClick(()=>{
            this.getUIContext().getPromptAction().showToast({message:'正在使用移动网络下载，请注意流量消耗'})
          })
      }

      Button('登录')
        .width('61.8%')

        .onClick(()=>{
            if(this.username == null || this.username.trim().length == 0){
              this.getUIContext().getPromptAction().showToast({message:'请输入用户名',duration:2000})

            }else if(!this.agree){
              this.getUIContext().getPromptAction().showToast({message:'请勾选《信息安全协议》',duration:2000})
            }
            //密码判断
            else if(this.password == null || this.password.trim().length == 0){
            this.getUIContext().getPromptAction().showToast({message:'密码不能为空',duration:2000})

            }
             else {
               //POST
               let url = 'http://192.168.100.1/api/user/login';
               //参数1 网址
               //参数2 参数
               //参数3 配置信息
               axios.post(url,{username:this.username,password:CryptoJS.MD5(this.password).toString()} as LoginUser,
                 {timeout:1000})
                 .then((resp:AxiosResponse)=>{
                   console.log(JSON.stringify(resp));
                   this.is_password_correct = resp.data.code;
                   if(this.is_password_correct=='0000000'){
                     //Cookie处理
                     //resp.headers.set-cookie 错误 中划线不符合命名规范
                     let cookies = resp.headers['set-cookie'] as string[];
                     let pref=preferences.getPreferencesSync(getContext(),{name:'zbox.xml'});
                     pref.deleteSync('cookie');
                     pref.putSync('cookie',cookies[cookies.length-1]);
                     pref.flushSync();
                     this.getUIContext().getPromptAction().showToast({message:'登录成功'})
                     //页面跳转 router
                     // replaceUrl():不能返回 直接被替换
                     //pushUrl():可以返回原页面
                     this.getUIContext().getRouter().replaceUrl({url:'pages/MainPage'});
                   } else {
                     this.getUIContext().getPromptAction().showToast({message:'用户名或密码错误'})
                   }
                 })
                 .catch((err:AxiosError)=>{
                   this.getUIContext().getPromptAction().showToast({message:err.message});
                 })


          }
        })

    }
    //.backgroundImage($r('app.media.login'))//图片命名符合规范,用变量命名方式，小写
    //.backgroundImageSize(ImageSize.FILL)//填充
    //.expandSafeArea([SafeAreaType.SYSTEM])
    .height('100%')
    .width('100%')
  }
}