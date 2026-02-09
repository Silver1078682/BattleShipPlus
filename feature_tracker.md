## 0.1.0(1)
- [x] 点亮后显示鱼雷值
- [x] 断网返回主界面/host&join加载返回主界面
- [x] C 平衡调整
- [x] 点亮后不显示血条
- [x] DD 正常检测 SS
- [x] UI 皮肤
- [x] 水纹效果地图
- [x] Exposure系统
- [x] ActionButton显示逻辑
- [x] 鱼雷用完后仍可攻击
---
- [x] Basic Unit tests
- [x] 指令系统

## 0.1.2
- [x] ActionButton FilterMask
- [x] 移动撤回反馈优化

## 0.2.0
- [x] !命令行接口重构
- [x] 地图选择
- [x] 血量攻击后立即更新
- [x] 可调动画速度
- [x] 修复move_ship顺序问题
- [x] AttackAnim 显示距离
- [x] CV平衡调整
- [x] Camera缩放移动限制
---
- [x] !重构Action类， 分离点亮和行为逻辑
  - [x] 加入ScopeMarker类， 用于点亮特定区域
- [x] !修改WarshipConfig中的 action_*属性 至 字典，使其更灵活
- [x] !Scope类改名MapLayer
- [x] 地图编辑器优化
  - [x] 更灵活的基地范围
  - [x] 基地坐标同步更新位置
- [x] 迁移godot4.6



## TODO
- [ ] 驱逐侦察潜艇Action
- [ ] Setting系统重构
- [ ] translation
- [ ] ActionButton 抢夺鼠标焦点
- [ ] 更复杂的移动逻辑（路径可达性检验）
- [ ] Card视觉效果优化
- [ ] 一个舰种的多种精灵图
