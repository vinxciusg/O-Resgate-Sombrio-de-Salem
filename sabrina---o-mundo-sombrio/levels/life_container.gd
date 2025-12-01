extends Control # Ou CanvasLayer, depende do que é sua raiz

# Aqui pegamos o caminho exato baseado na sua imagem
# life_container é o pai, life_counter é o filho (Label)
@onready var life_counter: Label = $life_counter

func _ready():
	# (Opcional) Teste para ver se o caminho está certo
	if life_counter == null:
		print("ERRO: Não achei o life_counter! Verifique o caminho.")

# Essa é a função que o Player vai chamar através do sinal
func atualizar_texto_vida(nova_vida):
	# Transforma o número em texto e muda na tela
	life_counter.text = "x " + str(nova_vida)


func _on_player_life_changed(player_health: Variant) -> void:
	pass # Replace with function body.
