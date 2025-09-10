extends Node

@export var mob_scene: PackedScene

@onready var player = $Player # อ้างอิงถึงโหนด Player
@onready var spawn_point = $SpawnPoint # อ้างอิงถึงโหนด Marker3D ที่ใช้เป็นจุดเกิด
@onready var score_label = $CanvasLayer/ScoreLabel # อ้างอิงถึงโหนด Label บน CanvasLayer

var score = 0 # ตัวแปรสำหรับเก็บคะแนน

func _ready():
	# เชื่อมต่อสัญญาณ 'hit' ของเพลเยอร์เข้ากับฟังก์ชัน on_player_hit
	player.hit.connect(_on_player_hit)
	
	# กำหนดตำแหน่งเริ่มต้นของเพลเยอร์
	player.global_position = spawn_point.global_position
	
	# อัปเดตคะแนนบน UI เมื่อเริ่มต้น
	update_score_label()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	# เชื่อมต่อสัญญาณ 'squashed' ของมอนสเตอร์เข้ากับฟังก์ชันเพิ่มคะแนน
	mob.squashed.connect(_on_mob_squashed)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_player_hit():
	# หยุดการสร้างมอนสเตอร์เมื่อเพลเยอร์ถูกชน
	$MobTimer.stop()
	
	# ซ่อนเพลเยอร์และทำให้ชนไม่ได้ชั่วคราว
	player.visible = false
	player.get_node("CollisionShape3D").disabled = true
	
	# เรียกฟังก์ชันเกิดใหม่
	respawn_player()


func respawn_player():
	# รอ 1 วินาทีก่อนเกิดใหม่
	await get_tree().create_timer(1.0).timeout
	
	# รีเซ็ตคะแนนเป็นศูนย์
	score = 0
	update_score_label()
	
	# ย้ายเพลเยอร์กลับไปยังจุดเกิด
	player.global_position = spawn_point.global_position
	
	# ทำให้เพลเยอร์กลับมามองเห็นได้และชนได้
	player.visible = true
	player.get_node("CollisionShape3D").disabled = false
	
	# รีเซ็ตความเร็วของเพลเยอร์
	player.target_velocity = Vector3.ZERO
	player.velocity = Vector3.ZERO
	
	# เริ่มการสร้างมอนสเตอร์อีกครั้ง
	$MobTimer.start()


func _on_mob_squashed():
	score += 1 # เพิ่มคะแนน
	update_score_label() # อัปเดต UI


func update_score_label():
	score_label.text = "Score: " + str(score)
