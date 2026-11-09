class_name DragonCatalog
extends Node

# Species definitions are independent of dragons owned by the player.
# Names describe the seven concepts from the original chibi request.
const SPECIES := [
	["fire", "Rồng Hỏa", ["Hỏa"], "Ngọn lửa nhỏ mang sức mạnh từ lòng đất.", "f5ad83", "fire"],
	["water", "Rồng Thủy", ["Thủy"], "Người bạn dịu dàng của những dòng suối cổ.", "79d7c6", "water"],
	["shadow", "Rồng Bóng Tối", ["Bóng Tối"], "Bí ẩn và tinh nghịch giữa màn đêm long động.", "ba9bea", "shadow"],
	["fire_water", "Rồng Hỏa · Thủy", ["Hỏa", "Thủy"], "Biến thể lai của hai dòng sức mạnh đối lập.", "e7b993", "fire_water"],
	["fire_shadow", "Rồng Hỏa · Bóng Tối", ["Hỏa", "Bóng Tối"], "Ngọn lửa tím ẩn mình trong bóng tối.", "d995bc", "fire_shadow"],
	["water_shadow", "Rồng Thủy · Bóng Tối", ["Thủy", "Bóng Tối"], "Dòng nước huyền bí phản chiếu ánh trăng.", "9baee9", "water_shadow"],
	["triple", "Rồng Tam Hệ", ["Hỏa", "Thủy", "Bóng Tối"], "Mẫu đặc biệt kết hợp cả ba nguyên tố.", "eacb83", "triple"],
]

static var _definitions: Array[DragonDefinition] = []

static func all_definitions() -> Array[DragonDefinition]:
	if not _definitions.is_empty():
		return _definitions.duplicate()
	var result: Array[DragonDefinition] = []
	for row in SPECIES:
		var definition := DragonDefinition.new()
		definition.id = row[0]
		definition.display_name = row[1]
		definition.elements.assign(row[2])
		definition.description = row[3]
		definition.accent = Color(row[4])
		definition.portrait = load("res://assets/textures/dragons/%s.png" % row[5])
		result.append(definition)
	_definitions = result
	return _definitions.duplicate()
