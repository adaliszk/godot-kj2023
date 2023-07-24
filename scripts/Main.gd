class_name Main
extends Node

@export var menu_container: Control
@export var start_button: Button
@export var view_switcher: TabBar
@export var view_container: Node
@export var is_started: bool:
	get:
		return _is_started
	set(value):
		if value:
			start()
		else:
			pause()

var views: Array = []

var _is_started = false


func _ready() -> void:
	start_button.connect("pressed", _on_start_pressed.bind(self))
	view_switcher.connect("tab_changed", _on_view_changed.bind(self))
	view_switcher.set_tab_hidden(1, true)
	view_switcher.set_tab_hidden(2, true)
	view_switcher.set_tab_hidden(3, true)

	views = [menu_container]

	RenderingServer.set_default_clear_color(Color.BLACK)
	GameTick.set_speed(GameTick.SPEED.TRIPLE)
	Log.info("GameSession::ready(): %s speed" % GameTick.get_speed())


func _on_view_changed(index: int, _event) -> void:
	Log.info("Main::on_view_changed(): %s" % index)
	if index == 0:
		start()
	else:
		pause()

	views[2].hide()
	views[3].hide()
	views[index].show()


func _on_start_pressed(_event) -> void:
	start()


func _input(event) -> void:
	if event.is_action_pressed("ui_pause") and is_started:
		pause()


func start() -> void:
	start_button.text = "  Continue"
	menu_container.hide()

	if not _is_started:
		var view1 = (preload("res://scenes/WorldMap.tscn")).instantiate()
		view_container.add_child(view1)
		view1.update_session()
		views.append(view1)
		view1.hide()

		var view2 = (preload("res://scenes/QuestManager.tscn")).instantiate()
		view_container.add_child(view2)
		view2.update_session()
		views.append(view2)
		view2.hide()

		var view3 = (preload("res://scenes/GuildManager.tscn")).instantiate()
		view_container.add_child(view3)
		view3.update_session()
		views.append(view3)
		view3.hide()

		view_switcher.set_tab_hidden(1, false)
		view_switcher.set_tab_hidden(2, false)
		view_switcher.set_tab_hidden(3, false)
		view_switcher.current_tab = 1
		view1.show()
		_is_started = true


func pause() -> void:
	view_switcher.current_tab = 0
	GameTick.stop_ticks()
