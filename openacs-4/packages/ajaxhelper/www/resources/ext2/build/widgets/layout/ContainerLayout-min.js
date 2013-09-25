/*
 * Ext JS Library 2.0
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

Ext.layout.ContainerLayout=function(A){Ext.apply(this,A)};Ext.layout.ContainerLayout.prototype={monitorResize:false,activeItem:null,layout:function(){var A=this.container.getLayoutTarget();this.onLayout(this.container,A);this.container.fireEvent("afterlayout",this.container,this)},onLayout:function(A,B){this.renderAll(A,B)},isValidParent:function(C,B){var A=C.getPositionEl?C.getPositionEl():C.getEl();return A.dom.parentNode==B.dom},renderAll:function(D,E){var B=D.items.items;for(var C=0,A=B.length;C<A;C++){var F=B[C];if(F&&(!F.rendered||!this.isValidParent(F,E))){this.renderItem(F,C,E)}}},renderItem:function(C,A,B){if(C&&!C.rendered){if(this.extraCls){C.addClass(this.extraCls)}C.render(B,A);if(this.renderHidden&&C!=this.activeItem){C.hide()}}else{if(C&&!this.isValidParent(C,B)){if(this.extraCls){C.addClass(this.extraCls)}if(typeof A=="number"){A=B.dom.childNodes[A]}B.dom.insertBefore(C.getEl().dom,A||null);if(this.renderHidden&&C!=this.activeItem){C.hide()}}}},onResize:function(){if(this.container.collapsed){return }var A=this.container.bufferResize;if(A){if(!this.resizeTask){this.resizeTask=new Ext.util.DelayedTask(this.layout,this);this.resizeBuffer=typeof A=="number"?A:100}this.resizeTask.delay(this.resizeBuffer)}else{this.layout()}},setContainer:function(A){if(this.monitorResize&&A!=this.container){if(this.container){this.container.un("resize",this.onResize,this)}if(A){A.on("resize",this.onResize,this)}}this.container=A},parseMargins:function(B){var C=B.split(" ");var A=C.length;if(A==1){C[1]=C[0];C[2]=C[0];C[3]=C[0]}if(A==2){C[2]=C[0];C[3]=C[1]}return{top:parseInt(C[0],10)||0,right:parseInt(C[1],10)||0,bottom:parseInt(C[2],10)||0,left:parseInt(C[3],10)||0}}};Ext.Container.LAYOUTS["auto"]=Ext.layout.ContainerLayout;