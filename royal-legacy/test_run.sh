#!/bin/bash

# Caminho para o executável do Godot
GODOT_BIN="/home/ubuntu/Godot_v4.2.2-stable_linux.x86_64"

# Caminho para o projeto
PROJECT_PATH="/home/ubuntu/Royal_Legacy/Royal_Legacy/royal-legacy"

echo "Iniciando teste de execução do Godot (MR 5)..."
echo "----------------------------------------------------"

SAVE_DIR="/home/ubuntu/.local/share/godot/app_userdata/Royal Legacy"
mkdir -p "$SAVE_DIR"

# Executa o Godot e mostra toda a saída
$GODOT_BIN -q --path $PROJECT_PATH

echo "----------------------------------------------------"
echo "Teste de execução concluído."

rm -f "$SAVE_DIR/royal_legacy_save.json"
