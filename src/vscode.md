# 常用快捷键
## 缩进
1. `shift+>`
## 折叠
1. 使用折叠区域折叠:
选中代码行并按Ctrl+Shift+[ (或点击行号区域左侧的折叠按钮)来折叠所选行。再次按快捷键会展开折叠。
2. 使用 #region 和 #endregion 注释折叠:
    ```csharp
    #region MyRegion 
    // 这些代码会被折叠

    #endregion
    ```
    vscode会自动把#region和#endregion之间的代码折叠起来。单击折叠条或按快捷键可以展开。
4. 在设置中配置要折叠的语言结构:
打开vscode设置(Ctrl+,或Code -> Preferences -> Settings),搜索"fold"找到编辑器中的折叠设置。
例如,要配置将C#中的命名空间、方法和属性折叠,可以添加如下设置:
json
"csharp.foldingRangeOptions": {
        "UseNamespaceFolding": true, 
        "UseMethodFolding": true,
        "UsePropertyFolding": true 
    }
之后打开的C#文件,名称空间、方法和属性会默认折叠。
5. 安装代码折叠扩展:
    你可以安装一些第三方扩展来获得更丰富的折叠配置和体验。比如:
    - Code Folding - 提供更丰富的折叠选项和UI
    - Rainbow Fold - 为不同的折叠层次着色,更易视觉识别
    - Fold Comments - 让你基于注释来定义折叠区段
