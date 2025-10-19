extends Panel

# Node references
@onready var goods_container: VBoxContainer = $HBoxMain/LeftPanel/GoodsContainer
@onready var inventory_list: VBoxContainer = $HBoxMain/RightPanel/InventoryList
@onready var inventory_value: Label = $HBoxMain/RightPanel/InventoryValue
@onready var transaction_log: RichTextLabel = $HBoxMain/RightPanel/TransactionLog
@onready var auto_refresh_toggle: CheckButton = $HBoxMain/LeftPanel/AutoRefreshToggle

# Data
var goods_list = ["rice", "timber", "tin", "hides", "sappan", "silver"]
var inventory := {}
var transaction_history := []
var first_trade_goods := {}  # Track first trades for prestige bonus
var price_flash_timer := 0.0
var last_prices := {}

func _ready() -> void:
	# Initialize inventory
	for goods in goods_list:
		inventory[goods] = 0
		first_trade_goods[goods] = false
		last_prices[goods] = Market.get_price(goods)
	
	# Create UI
	_create_goods_rows()
	_update_inventory_display()
	
	# Connect signals
	Market.price_changed.connect(_on_price_changed)
	auto_refresh_toggle.toggled.connect(_on_auto_refresh_toggled)
	
	# Add initial transaction log entry
	_add_transaction_log("Market opened for trading", Color.WHITE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_trade"):
		visible = !visible

func _process(delta: float) -> void:
	# Handle price flash animation
	if price_flash_timer > 0:
		price_flash_timer -= delta
		if price_flash_timer <= 0:
			_reset_price_colors()

func _create_goods_rows() -> void:
	"""Create UI rows for each goods type"""
	for goods in goods_list:
		var row = _create_goods_row(goods)
		goods_container.add_child(row)

func _create_goods_row(goods: String) -> HBoxContainer:
	"""Create a single goods row with price and buy/sell controls"""
	var hbox = HBoxContainer.new()
	hbox.name = goods + "_row"
	
	# Goods name
	var name_label = Label.new()
	name_label.text = goods.capitalize()
	name_label.custom_minimum_size.x = 80
	hbox.add_child(name_label)
	
	# Price label
	var price_label = Label.new()
	price_label.name = goods + "_price"
	price_label.text = str(Market.get_price(goods))
	price_label.custom_minimum_size.x = 50
	hbox.add_child(price_label)
	
	# Buy buttons
	for amount in [1, 5, 10]:
		var buy_btn = Button.new()
		buy_btn.text = "Buy " + str(amount)
		buy_btn.custom_minimum_size.x = 60
		buy_btn.pressed.connect(_on_buy_pressed.bind(goods, amount))
		hbox.add_child(buy_btn)
	
	# Sell buttons
	for amount in [1, 5, 10]:
		var sell_btn = Button.new()
		sell_btn.text = "Sell " + str(amount)
		sell_btn.custom_minimum_size.x = 60
		sell_btn.pressed.connect(_on_sell_pressed.bind(goods, amount))
		hbox.add_child(sell_btn)
	
	return hbox

func _on_buy_pressed(goods: String, amount: int) -> void:
	"""Handle buy button press"""
	var price = Market.get_price(goods)
	var total_cost = price * amount
	
	# Check if player has enough silver
	if Game.silver < total_cost:
		_add_transaction_log("Insufficient silver for " + str(amount) + " " + goods, Color.RED)
		return
	
	# Process transaction
	Game.add_silver(-total_cost)
	inventory[goods] += amount
	
	# First trade prestige bonus
	if not first_trade_goods[goods]:
		first_trade_goods[goods] = true
		Game.add_prestige(1)
		_add_transaction_log("First " + goods + " trade! +1 Prestige", Color.GOLD)
	
	# Log transaction
	var msg = "Bought " + str(amount) + " " + goods + " @ " + str(price) + " (-" + str(total_cost) + ")"
	_add_transaction_log(msg, Color.GREEN)
	
	_update_inventory_display()

func _on_sell_pressed(goods: String, amount: int) -> void:
	"""Handle sell button press"""
	# Check if player has enough goods
	if inventory[goods] < amount:
		_add_transaction_log("Insufficient " + goods + " to sell", Color.RED)
		return
	
	var price = Market.get_price(goods)
	var total_value = price * amount
	
	# Process transaction
	Game.add_silver(total_value)
	inventory[goods] -= amount
	
	# First trade prestige bonus
	if not first_trade_goods[goods]:
		first_trade_goods[goods] = true
		Game.add_prestige(1)
		_add_transaction_log("First " + goods + " trade! +1 Prestige", Color.GOLD)
	
	# Log transaction
	var msg = "Sold " + str(amount) + " " + goods + " @ " + str(price) + " (+" + str(total_value) + ")"
	_add_transaction_log(msg, Color.CYAN)
	
	_update_inventory_display()

func _on_price_changed(goods: String, new_price: int) -> void:
	"""Handle price changes from Market"""
	var price_label = goods_container.get_node_or_null(goods + "_row/" + goods + "_price")
	if price_label:
		price_label.text = str(new_price)
		
		# Flash price if auto-refresh is enabled and price changed significantly
		if auto_refresh_toggle.button_pressed:
			var old_price = last_prices.get(goods, new_price)
			if abs(new_price - old_price) > 0:
				if new_price > old_price:
					price_label.modulate = Color.GREEN
				else:
					price_label.modulate = Color.RED
				price_flash_timer = 1.0  # Flash for 1 second
	
	last_prices[goods] = new_price
	_update_inventory_display()  # Update total value

func _on_auto_refresh_toggled(enabled: bool) -> void:
	"""Handle auto-refresh toggle"""
	if enabled:
		_add_transaction_log("Auto price refresh enabled", Color.YELLOW)
	else:
		_add_transaction_log("Auto price refresh disabled", Color.YELLOW)
		_reset_price_colors()

func _reset_price_colors() -> void:
	"""Reset all price label colors to default"""
	for goods in goods_list:
		var price_label = goods_container.get_node_or_null(goods + "_row/" + goods + "_price")
		if price_label:
			price_label.modulate = Color.WHITE

func _update_inventory_display() -> void:
	"""Update inventory list and total value"""
	# Clear existing inventory display
	for child in inventory_list.get_children():
		child.queue_free()
	
	# Add inventory items
	var total_value = 0
	for goods in goods_list:
		var amount = inventory[goods]
		if amount > 0:
			var hbox = HBoxContainer.new()
			
			var goods_label = Label.new()
			goods_label.text = goods.capitalize() + ":"
			goods_label.custom_minimum_size.x = 80
			hbox.add_child(goods_label)
			
			var amount_label = Label.new()
			amount_label.text = str(amount)
			amount_label.custom_minimum_size.x = 40
			hbox.add_child(amount_label)
			
			var value = Market.get_price(goods) * amount
			total_value += value
			
			var value_label = Label.new()
			value_label.text = "(" + str(value) + ")"
			hbox.add_child(value_label)
			
			inventory_list.add_child(hbox)
	
	# Update total value
	inventory_value.text = "Total Value: " + str(total_value)

func _add_transaction_log(message: String, color: Color) -> void:
	"""Add entry to transaction log"""
	transaction_history.append({"message": message, "color": color})
	
	# Keep only last 10 entries
	if transaction_history.size() > 10:
		transaction_history.pop_front()
	
	# Update log display
	var log_text = ""
	for entry in transaction_history:
		var color_hex = entry.color.to_html()
		log_text += "[color=" + color_hex + "]" + entry.message + "[/color]\n"
	
	transaction_log.text = log_text
