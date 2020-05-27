package kabam.rotmg.market.utils {
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import flash.events.Event;
   
   public class DialogUtils {
       
      
      public function DialogUtils() {
         super();
      }
      
      public static function makeSimpleDialog(gameSprite:GameSprite, title:String, description:String) : void {
         var dialog:Dialog = new Dialog(description,title,"Close",null,true);
         dialog.addEventListener(Dialog.BUTTON1_EVENT,onDialogClose);
         gameSprite.mui_.layers.overlay.addChild(dialog);
      }
      
      public static function makeCallbackDialog(gameSprite:GameSprite, title:String, description:String, textOne:String, textTwo:String, callback:Function) : void {
         var dialog:Dialog = new Dialog(description,title,textOne,textTwo,true);
         dialog.addEventListener(Dialog.BUTTON1_EVENT,callback);
         dialog.addEventListener(Dialog.BUTTON1_EVENT,onDialogClose);
         dialog.addEventListener(Dialog.BUTTON2_EVENT,onDialogClose);
         gameSprite.mui_.layers.overlay.addChild(dialog);
      }
      
      public static function onDialogClose(event:Event) : void {
         var dialog:Dialog = event.currentTarget as Dialog;
         dialog.removeEventListener(Dialog.BUTTON1_EVENT,onDialogClose);
         dialog.removeEventListener(Dialog.BUTTON2_EVENT,onDialogClose);
         dialog.parent.removeChild(dialog);
      }
      
      public function returnDialog(gameSprite:GameSprite, title:String, description:String, textOne:String, textTwo:String) : Dialog {
         var dialog:Dialog = new Dialog(description,title,textOne,textTwo,true);
         return dialog;
      }
   }
}
