extends Node2D

signal restart

var score := 0

func showGameOver():
	$GameOverLabel.text = "GAME OVER"
	$ColorRect.visible = true
	$Score.valign = VALIGN_CENTER
	$Score.set("custom_colors/font_color", Color(0.0, 0.0, 0.0))
	$Score.get_font("font").size = 40
	$Button.visible = true

func updateScore():
	score += 1
	$Score.text = "\nScore: " + str(score)

func _on_Button_pressed():
	$GameOverLabel.text = ""
	$ColorRect.visible = false
	$Score.valign = VALIGN_TOP
	$Score.set("custom_colors/font_color", Color(1.0, 1.0, 1.0))
	$Score.get_font("font").size = 20
	$Button.visible = false
	score = -1
	updateScore()
	emit_signal("restart")


func _on_StartButton_pressed():
	$ColorRect.visible = false
	$Score.visible = true
	$StartButton.visible = false
	$Header.visible = false
	emit_signal("restart")
