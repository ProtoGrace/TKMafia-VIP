package kabam.rotmg.market {
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.ui.options.Options;
   import com.company.assembleegameclient.ui.options.OptionsTabTitle;
   import com.company.ui.SimpleText;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.text.TextFieldAutoSize;
   import io.decagames.rotmg.ui.buttons.SliceScalingButton;
   import io.decagames.rotmg.ui.popups.header.PopupHeader;
   import io.decagames.rotmg.ui.sliceScaling.SliceScalingBitmap;
   import io.decagames.rotmg.ui.texture.TextureParser;
   import kabam.rotmg.market.tabs.MemMarketBuyTab;
   import kabam.rotmg.market.tabs.MemMarketSellTab;
   import kabam.rotmg.market.tabs.MemMarketTab;
   import kabam.rotmg.ui.view.components.MenuOptionsBar;
   
   public class MemMarket extends Sprite {
      
      private static const BUY:String = "Buy";
      
      private static const SELL:String = "Sell";
      
      private static const TABS:Vector.<String> = new <String>[BUY,SELL];
       
      
      private var gameSprite_:GameSprite;
      
      private var titleText_:SimpleText;
      
      private var header_:PopupHeader;
      
      private var menuOptionsBar_:MenuOptionsBar;
      
      private var closeButton_:SliceScalingButton;
      
      private var doneButton_:SliceScalingButton;
      
      private var background_:SliceScalingBitmap;
      
      private var tabs_:Vector.<OptionsTabTitle>;
      
      private var content_:Vector.<MemMarketTab>;
      
      private var selectedTab_:OptionsTabTitle;
      
      public function MemMarket(gameSprite:GameSprite) {
         var tab:OptionsTabTitle = null;
         super();
         this.gameSprite_ = gameSprite;
         graphics.clear();
         graphics.beginFill(2829099,0.8);
         graphics.drawRect(0,0,800,600);
         graphics.endFill();
         graphics.lineStyle(1,6184542);
         graphics.moveTo(0,100);
         graphics.lineTo(800,100);
         graphics.lineStyle();
         this.titleText_ = new SimpleText(24,16777215,false,800,0);
         this.titleText_.setBold(true);
         this.titleText_.setText("5% Tax");
         this.titleText_.autoSize = TextFieldAutoSize.LEFT;
         this.titleText_.filters = [new DropShadowFilter(0,0,0)];
         this.titleText_.updateMetrics();
         this.titleText_.x = 800 / 2 - 50 + 250;
         this.titleText_.y = 30;
         this.menuOptionsBar_ = new MenuOptionsBar();
         this.background_ = SliceScalingBitmap(TextureParser.instance.getSliceScalingBitmap("UI","popup_header_title",800));
         this.background_.y = 516.5;
         addChild(this.background_);
         this.doneButton_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","generic_green_button"));
         this.doneButton_.addEventListener(MouseEvent.CLICK,this.onClose);
         this.closeButton_ = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","close_button"));
         this.closeButton_.addEventListener(MouseEvent.CLICK,this.onClose);
         this.header_ = new PopupHeader(800,PopupHeader.TYPE_FULL);
         this.header_.setTitle("Market",319,null);
         this.header_.showFame(132).fameAmount = this.gameSprite_.map.player_.fame_;
         this.header_.addButton(this.closeButton_,PopupHeader.RIGHT_BUTTON,-15);
         this.menuOptionsBar_.addButton(this.doneButton_,MenuOptionsBar.CENTER);
         Options.setDefault(this.doneButton_,"Done",100,false);
         this.doneButton_.y = 535;
         this.doneButton_.x = 800 / 2 - 50;
         addChild(this.menuOptionsBar_);
         addChild(this.header_);
         addChild(this.titleText_);
         this.tabs_ = new Vector.<OptionsTabTitle>();
         var xOffset:int = 14;
         for(var i:int = 0; i < TABS.length; i++) {
            tab = new OptionsTabTitle(TABS[i]);
            tab.x = xOffset;
            tab.y = 78;
            tab.addEventListener(MouseEvent.CLICK,this.onTab);
            addChild(tab);
            this.tabs_.push(tab);
            xOffset = xOffset + 108;
         }
         this.content_ = new Vector.<MemMarketTab>();
         this.setTab(this.tabs_[0]);
      }
      
      private function onTab(event:Event) : void {
         var tab:OptionsTabTitle = event.target as OptionsTabTitle;
         this.setTab(tab);
      }
      
      private function setTab(tab:OptionsTabTitle) : void {
         var i:MemMarketTab = null;
         if(tab == this.selectedTab_) {
            return;
         }
         if(this.selectedTab_ != null) {
            this.selectedTab_.setSelected(false);
         }
         this.selectedTab_ = tab;
         this.selectedTab_.setSelected(true);
         for each(i in this.content_) {
            i.dispose();
            removeChild(i);
         }
         this.content_.length = 0;
         switch(this.selectedTab_.text_) {
            case SELL:
               this.addContent(new MemMarketSellTab(this.gameSprite_));
               break;
            case BUY:
               this.addContent(new MemMarketBuyTab(this.gameSprite_));
         }
      }
      
      private function addContent(content:MemMarketTab) : void {
         this.addChild(content);
         this.content_.push(content);
      }
      
      private function removeLastContent() : void {
      }
      
      private function onClose(event:Event) : void {
         var tab:OptionsTabTitle = null;
         var content:MemMarketTab = null;
         var i:int = 0;
         this.gameSprite_.mui_.setEnableHotKeysInput(true);
         this.gameSprite_.mui_.setEnablePlayerInput(true);
         this.gameSprite_ = null;
         this.titleText_ = null;
         this.closeButton_.removeEventListener(MouseEvent.CLICK,this.onClose);
         this.closeButton_ = null;
         for each(tab in this.tabs_) {
            tab.removeEventListener(MouseEvent.CLICK,this.onTab);
            tab = null;
         }
         this.tabs_.length = 0;
         this.tabs_ = null;
         for each(content in this.content_) {
            content.dispose();
            content = null;
         }
         this.content_.length = 0;
         this.content_ = null;
         this.selectedTab_ = null;
         for(i = numChildren - 1; i >= 0; i--) {
            removeChildAt(i);
         }
         stage.focus = null;
         parent.removeChild(this);
      }
   }
}
