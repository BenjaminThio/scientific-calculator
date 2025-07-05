extends Label

func _draw() -> void:
	draw_polyline([
		Vector2(size.x, 0),
		Vector2(size.x / 3, size.y),
		Vector2(size.x / 5, size.y * 4 / 5),
		Vector2(0, size.y * 6 / 7)
	], Color.WHITE, 2.0)

"""
# Power

entries.append(Entry.new(Global.TYPE.POWER, {
	base = Entry.new(Global.TYPE.NUMBER, '2'),
	exponent = [
		Entry.new(
			Global.TYPE.POWER, {
				base = Entry.new(Global.TYPE.NUMBER, '2'),
				exponent = [
					Entry.new(
						Global.TYPE.POWER, {
							base = Entry.new(Global.TYPE.NUMBER, '2'),
							exponent = [
								Entry.new(Global.TYPE.NUMBER, '1'),
								Entry.new(Global.TYPE.OPERATOR, '×'),
								Entry.new(Global.TYPE.NUMBER, '2'),
								Entry.new(Global.TYPE.OPERATOR, '×'),
								Entry.new(Global.TYPE.FUNCTION, 'cos('),
								Entry.new(Global.TYPE.NUMBER, '0'),
								Entry.new(Global.TYPE.OPERATOR, ')')
							]
						}
					),
					Entry.new(Global.TYPE.OPERATOR, '×'),
					Entry.new(Global.TYPE.NUMBER, '1')
				]
			}
		)
	]
}))

# Log

entries.append(Entry.new(Global.TYPE.LOGARITHM, {
	base = [Entry.new(
		Global.TYPE.POWER, {
			base = Entry.new(Global.TYPE.NUMBER, '8'),
			exponent = [Entry.new(Global.TYPE.NUMBER, '5')]
		}
	), Entry.new(Global.TYPE.OPERATOR, '+'), Entry.new(Global.TYPE.NUMBER, '7')],
	argument = [Entry.new(Global.TYPE.POWER, {
		base = Entry.new(Global.TYPE.NUMBER, '2'),
		exponent = [
			Entry.new(
				Global.TYPE.POWER, {
					base = Entry.new(Global.TYPE.NUMBER, '2'),
					exponent = [
						Entry.new(
							Global.TYPE.POWER, {
								base = Entry.new(Global.TYPE.NUMBER, '2'),
								exponent = [
									Entry.new(Global.TYPE.NUMBER, '1'),
									Entry.new(Global.TYPE.OPERATOR, '×'),
									Entry.new(Global.TYPE.NUMBER, '2'),
									Entry.new(Global.TYPE.OPERATOR, '×'),
									Entry.new(Global.TYPE.FUNCTION, 'cos('),
									Entry.new(Global.TYPE.NUMBER, '0'),
									Entry.new(Global.TYPE.OPERATOR, ')')
								]
							}
						),
						Entry.new(Global.TYPE.OPERATOR, '×'),
						Entry.new(Global.TYPE.NUMBER, '1')
					]
				}
			)
		]
	})]
}))
"""
