# RichEditor
富文本编辑器

运行环境：iOS 9.0 ，Swift 4.2


支持MD与RTF编辑

使用runtime替换WKWebview的contentView，支持点击可编辑区域，弹出我们的toolbar作为inputAccessoryView。
Hook WKWebview的`startAssistingNode:userIsInteracting:blurPreviousNode:userObject`方法，设置允许JS触发编辑框来弹出键盘。

使用简单，体验较好
<div width = "800">
  <img src="https://github.com/meng03/Resource/blob/master/RichEditor2.PNG" width = "400" float=right />
</div>
