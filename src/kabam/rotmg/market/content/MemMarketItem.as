package kabam.rotmg.market.content {
   import com.company.assembleegameclient.constants.InventoryOwnerTypes;
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
   import com.company.assembleegameclient.ui.tooltip.ToolTip;
   import flash.display.Bitmap;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import kabam.rotmg.messaging.impl.data.MarketData;
   
   public class MemMarketItem extends Sprite {
      
      public static const OFFER_WIDTH:int = 100;
      
      public static const OFFER_HEIGHT:int = 83;
      
      public static const SLOT_WIDTH:int = 50;
      
      public static const SLOT_HEIGHT:int = 50;
       
      
      public var gameSprite_:GameSprite;
      
      public var itemType_:int;
      
      public var id_:int;
      
      public var data_:MarketData;
      
      public var shape_:Shape;
      
      public var icon_:Bitmap;
      
      public var toolTip_:ToolTip;
      
      public function MemMarketItem(gameSprite:GameSprite, width:int, height:int, iconSize:int, itemType:int, data:MarketData) {
         super();
         this.gameSprite_ = gameSprite;
         this.itemType_ = itemType;
         this.id_ = data == null?int(-1):int(data.id_);
         this.data_ = data;
         this.shape_ = new Shape();
         drawRoundRectAsFill(this.shape_.graphics,0,0,width,height,5);
         addChild(this.shape_);
         if(this.itemType_ != -1) {
            this.icon_ = new Bitmap(ObjectLibrary.getRedrawnTextureFromType(this.itemType_,iconSize,true));
            this.icon_.x = -3;
            this.icon_.y = -3;
            addChild(this.icon_);
            addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         }
      }
      
      public static function drawRoundRectAsFill(graphics:Graphics, x:Number, y:Number, w:Number, h:Number, radius:Number, lineColor:uint = 6776679, fillColor:uint = 4539717, lineThickness:Number = 1, lineAlpha:Number = 1, fillAlpha:Number = 1) : void {
         graphics.lineStyle(0,0,0);
         graphics.beginFill(lineColor,lineAlpha);
         graphics.drawRoundRect(x,y,w,h,2 * radius,2 * radius);
         graphics.drawRoundRect(x + lineThickness,y + lineThickness,w - 2 * lineThickness,h - 2 * lineThickness,2 * radius - 2 * lineThickness,2 * radius - 2 * lineThickness);
         graphics.endFill();
         graphics.beginFill(fillColor,fillAlpha);
         graphics.drawRoundRect(x + lineThickness,y + lineThickness,w - 2 * lineThickness,h - 2 * lineThickness,2 * radius - 2 * lineThickness,2 * radius - 2 * lineThickness);
         graphics.endFill();
      }
      
      protected function removeListeners() : void {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
      }
      
      private function onOver(event:MouseEvent) : void {
         this.toolTip_ = new EquipmentToolTip(this.itemType_,this.gameSprite_.map.player_,-1,InventoryOwnerTypes.NPC,1,true);
         this.gameSprite_.mui_.layers.overlay.addChild(this.toolTip_);
         this.toolTip_.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.icon_.alpha = 0.7;
      }
      
      private function onEnterFrame(evt:Event) : void {
         if(stage == null) {
            return;
         }
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = 800 / stage.stageWidth;
         var _loc4_:Number = 600 / stage.stageHeight;
         _loc1_ = (stage.mouseX + stage.stageWidth / 2 - 400) / stage.stageWidth * 800;
         _loc2_ = (stage.mouseY + stage.stageHeight / 2 - 300) / stage.stageHeight * 600;
         _loc1_ = (stage.stageWidth - 800) / 2 + stage.mouseX;
         _loc2_ = (stage.stageHeight - 600) / 2 + stage.mouseY;
         this.toolTip_.parent.scaleX = _loc3_;
         this.toolTip_.parent.scaleY = _loc4_;
         this.toolTip_.x = _loc1_ + 12;
         this.toolTip_.y = _loc2_ + 12;
      }
      
      private function onOut(event:MouseEvent) : void {
         this.toolTip_.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.toolTip_.parent.removeChild(this.toolTip_);
         this.toolTip_ = null;
         this.icon_.alpha = 1;
      }
      
      public function dispose() : void {
         this.gameSprite_ = null;
         this.shape_ = null;
         this.icon_ = null;
         if(this.toolTip_ != null) {
            this.toolTip_.parent.removeChild(this.toolTip_);
            this.toolTip_ = null;
         }
         this.removeListeners();
         for(var i:int = numChildren - 1; i >= 0; i--) {
            removeChildAt(i);
         }
      }
   }
}
