package com.company.assembleegameclient.ui.tooltip.controller {
import kabam.rotmg.core.signals.HideTooltipsSignal;
import kabam.rotmg.core.signals.ShowTooltipSignal;

public interface TooltipAble {


    function setShowToolTipSignal(param1:ShowTooltipSignal):void;

    function getShowToolTip():ShowTooltipSignal;

    function setHideToolTipsSignal(param1:HideTooltipsSignal):void;

    function getHideToolTips():HideTooltipsSignal;
}
}
