class_name BattleUnitData
extends Resource

var id := ""
var display_name := ""
var side := "player"
var element := ""
var max_hp := 1
var hp := 1
var attack := 1.0
var defense := 0.0
var speed := 1
var shield := 0
var skill := "basic"
var skills: Array[String] = []
var cooldowns := {}
var statuses := {}
var immunities: Array = []
var ai := ""
var intent := ""
var enrage := {}
var enraged := false
var passive_name := ""
var portrait: Texture2D

func alive() -> bool:
	return hp > 0
