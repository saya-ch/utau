extends SceneTree
## Voxglass 截图捕获工具 (T083)
##
## 用法:
##   godot --headless --display-driver headless --rendering-driver opengl3 \
##         --path /workspace -s tools/screenshot_capture.gd -- \
##         <scene_path> <out_png> [wait_frames=45]
##
## 工作原理:
##   - 继承 SceneTree 而不是 Node，用作 main loop
##   - 用户参数通过 `--` 之后的 OS.get_cmdline_user_args() 读取
##   - 实例化目标场景，添加到 root
##   - 等待 N 个 process_frame 让场景 _ready / autoload / BGM 合成完成
##   - 调用 root.get_viewport().get_texture().get_image() 抓帧
##   - save_png() 到指定路径，quit()
##
## 沙箱适配:
##   - headless display + opengl3 rendering driver
##   - 无 Xvfb；ViewPort 仍然会渲染到 framebuffer
##   - 480x270 内部 viewport 直接抓 1920x1080 拉伸后的图像

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("screenshot_capture: 需要 <scene_path> <out_png> [wait_frames]")
		print("用法: godot --headless --path /workspace -s tools/screenshot_capture.gd -- <scene> <out> [frames]")
		quit(1)
		return

	var scene_path: String = args[0]
	var out_path: String = args[1]
	var wait_frames: int = 45
	if args.size() >= 3:
		wait_frames = int(args[2])

	print("[screenshot_capture] scene=%s out=%s wait_frames=%d" % [scene_path, out_path, wait_frames])

	# 确保输出目录存在
	var out_dir := out_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(out_dir):
		var err := DirAccess.make_dir_recursive_absolute(out_dir)
		if err != OK:
			push_error("screenshot_capture: 无法创建目录 %s (err=%d)" % [out_dir, err])
			quit(1)
			return

	# 加载目标场景
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("screenshot_capture: 加载失败 %s" % scene_path)
		quit(1)
		return

	var inst: Node = packed.instantiate()
	if inst == null:
		push_error("screenshot_capture: 实例化失败 %s" % scene_path)
		quit(1)
		return

	root.add_child(inst)
	print("[screenshot_capture] scene loaded, waiting %d frames..." % wait_frames)

	# 等待 N 帧让场景 + autoload + BGM 全部就位
	for i in range(wait_frames):
		await process_frame
		# 每 15 帧给个心跳日志
		if i % 15 == 0:
			print("[screenshot_capture] frame %d/%d" % [i, wait_frames])

	print("[screenshot_capture] capturing viewport...")

	# 抓取主 viewport
	var vp := root.get_viewport()
	if vp == null:
		push_error("screenshot_capture: root.get_viewport() 返回 null")
		quit(1)
		return

	# 强制渲染一次以确保 framebuffer 是新的
	RenderingServer.force_sync()
	await process_frame

	var img: Image = vp.get_texture().get_image()
	if img == null or img.is_empty():
		push_error("screenshot_capture: 抓取图像为空（可能渲染器未初始化）")
		quit(1)
		return

	print("[screenshot_capture] image size=%dx%d" % [img.get_width(), img.get_height()])

	var save_err := img.save_png(out_path)
	if save_err != OK:
		push_error("screenshot_capture: 保存失败 %s (err=%d)" % [out_path, save_err])
		quit(1)
		return

	print("[screenshot_capture] saved %s" % out_path)
	quit(0)
