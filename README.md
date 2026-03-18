# 🏰 Royal Legacy

**Royal Legacy** é um jogo de **xadrez desenvolvido em Godot**, combinando a elegância clássica do tabuleiro com uma atmosfera real e imersiva digna de um verdadeiro legado real.

[![Godot Engine](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?style=for-the-badge&logo=godot-engine)](https://godotengine.org/)
[![Linguagem](https://img.shields.io/badge/Linguagem-GDScript-478cbf?style=for-the-badge&logo=gdscript)](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html)
[![Licença](https://img.shields.io/badge/Licença-MIT-green?style=for-the-badge)](LICENSE)

---

## ♟️ Sobre o Jogo

Em **Royal Legacy**, o tradicional jogo de xadrez ganha uma nova vida. A proposta é oferecer uma experiência visual refinada, com interface moderna e sons envolventes — mantendo toda a profundidade estratégica que consagrou o xadrez como um dos jogos mais desafiadores do mundo.

O foco do projeto é unir **jogabilidade clássica**, **design minimalista** e **tecnologia Godot Engine**, tornando-o uma base sólida tanto para aprendizado quanto para expansão futura (como modos online, IA personalizada e temas visuais dinâmicos).

---

## ✨ Funcionalidades Principais

| Categoria | Funcionalidade | Detalhes |
| :--- | :--- | :--- |
| **Jogabilidade** | Tabuleiro totalmente jogável | Implementação completa das regras básicas do xadrez. |
| **Regras** | Movimentação válida de peças | Verificação de movimentos para todas as peças (Peão, Torre, Cavalo, Bispo, Rainha, Rei). |
| **Interface** | Design Limpo e Responsivo | Interface minimalista em estilo “Royal Board” que se adapta a diferentes resoluções. |
| **Imersão** | Efeitos Sonoros | Efeitos sonoros sutis para cada movimento e evento de jogo. |
| **Controle** | Reinício Rápido | Sistema de reinício de partida com a tecla `R`. |
| **Visual** | Temas Visuais | Inclui múltiplos temas visuais inspirados em reinos e heranças reais (arquivos em `royal-legacy/temas/`). |

---

## 🛠️ Tecnologias Utilizadas

Este projeto foi desenvolvido utilizando a **Godot Engine**, uma poderosa ferramenta *open-source* para criação de jogos.

*   **Engine:** [Godot 4.x](https://godotengine.org/)
*   **Linguagem:** GDScript
*   **Design:** Interface minimalista em estilo “Royal Board”
*   **Controle de Versão:** Git + GitHub

---

## 🚀 Como Executar o Projeto

Para rodar o **Royal Legacy** em sua máquina e ter a experiência completa jogando contra a IA, siga os passos abaixo.

### 1. Pré-requisitos

Certifique-se de ter os seguintes programas instalados:

* **[Godot Engine 4.x](https://godotengine.org/download)** (versão padrão).
* **[Python 3.x](https://www.python.org/downloads/)** (⚠️ **Importante:** marque a caixa *"Add Python to PATH"* durante a instalação).
* **[Stockfish](https://stockfishchess.org/download)** (versão recomendada: Stockfish 18 ou superior).

### 2. Instalação e Configuração

1.  **Clone o repositório** para sua máquina local:
    ```bash
    git clone [https://github.com/seu-usuario/royal-legacy.git](https://github.com/seu-usuario/royal-legacy.git)
    ```

2.  **Navegue até o diretório do projeto Godot**:
    *(O projeto Godot está aninhado em uma subpasta chamada `royal-legacy`)*
    ```bash
    cd royal-legacy/royal-legacy
    ```

3.  **Instale as dependências da IA:** Abra o terminal (ou Prompt de Comando) e instale a biblioteca de xadrez do Python executando:
    ```bash
    pip install chess
    ```

4.  **Adicione o motor Stockfish:** Extraia o arquivo baixado do Stockfish, pegue o executável (`stockfish.exe`) e coloque-o **dentro da pasta `scripts/`** do projeto.

5.  **Ajuste o caminho da IA (Importante):** Abra o arquivo `scripts/chess_bridge.py` no seu editor de texto e certifique-se de que a variável `caminho_stockfish` aponta para o local correto onde você colocou o `.exe` na sua máquina.

### 3. Execução

* Abra o **Godot Engine**.
* Clique em **Importar** e selecione o arquivo `project.godot` dentro da pasta `royal-legacy`.
* Com o projeto aberto, clique no botão **Play** (ou pressione `F5`) para iniciar a partida.

---

## 🕹️ Controles

| Ação | Tecla / Mouse |
| :--- | :--- |
| **Selecionar peça** | Clique com o botão esquerdo |
| **Mover peça** | Clique no destino válido |
| **Reiniciar partida** | Tecla `R` |
| **Sair do jogo** | Tecla `Esc` |

---

## 📂 Estrutura do Projeto

A estrutura de arquivos do projeto Godot (`royal-legacy/`) é organizada da seguinte forma:

```
royal-legacy/
├── assets/             # Imagens das peças de xadrez e sprites
├── fontes/             # Arquivos de fontes (.ttf) utilizadas no projeto
├── scripts/            # Scripts GDScript, incluindo o GameManager.gd
├── temas/              # Arquivos de imagem para os temas visuais do tabuleiro
├── menu_principal.tscn # Cena principal do jogo
├── project.godot       # Arquivo de configuração do Godot
└── icon.svg            # Ícone do projeto
```

---

## 🤝 Contribuidores

Este projeto foi desenvolvido por:

*   Danilo Matias
*   Davi Brito
*   João Paulo Moreira
*   Klayvert
*   Thierry Feitoza

---

## 📝 Licença

Este projeto está sob a licença **MIT**. Você tem a liberdade de estudar, modificar e compartilhar o código. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
