## _VerbAbilityBase
##
## 共享基类给 5 verb ability (pulse / bind / cut / echo / wave)。
##
## D002.B (#97) — 推 VerbWindupVFXBase 经验到 5 verb ability 家族。
## 5 verb ability 在 T181 (#97) 之前都已经复制粘贴了一份：
##   - _has_game_state_autoload() — 4 verb / Wave T173 (#92) 加了
##   - _has_audio_manager_enhanced() — T181 (#97) 在 5 verb 都加了
## 共 8 份 byte-identical 复制粘贴。 抽到本基类消除 8 重复，
## 后续 6 verb / 7 verb 加新的 shared helper (例如 _has_screenshot
## / _has_hud_layer / _has_game_logger) 只需改一处。
##
## 命名带下划线前缀 _VerbAbilityBase (GDScript 习惯: 基类下划
## 线前缀表明"我不应该被直接实例化, 只能被 extends")。 注意
## GDScript 的字段规则: 父类声明的字段被子类同名字段遮盖,
## 所以 5 verb ability 仍然在子类内声明 _cooldown_timer /
## _windup_timer 等 verb-specific 字段 (各 verb 行为差异较大
## 强抽会牺牲可读性)。 本基类**只**放共享的 autoload probe
## helper, 不动 verb-specific 字段。
##
## Future tasks that may add more shared helpers here:
##   - _has_hud_layer() for HUD wiring safety
##   - _has_screenshot_autoload() for screenshot capture in #XX
##   - _has_game_logger() for structured logging

class_name VerbAbilityBase
extends Node


# T181 (#97) — Audio autoload probe. Mirrors the 5 byte-identical
# copies that used to live in pulse/bind/cut/echo/wave ability.
# Returns true iff the AudioManagerEnhanced singleton is present
# in the SceneTree root, so callers can guard AudioManagerEnhanced.*
# calls without crashing in headless smoke tests or in pre-load
# frames where the autoload isn't ready yet.
func _has_audio_manager_enhanced() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("AudioManagerEnhanced")


# Mirror of _has_audio_manager_enhanced for the GameState singleton
# (PlayerStats, GameState.resonance, etc. all rely on it).  4 verb
# abilities had this before T181 (#97) (pulse/bind/cut/echo); Wave
# got it in T173 (#92) so it could probe the wave_radius_bonus
# generator.  Now all 5 share one canonical implementation.
func _has_game_state_autoload() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	return tree.root.has_node("GameState")
