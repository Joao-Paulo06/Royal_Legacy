import sys
import json
import chess
import chess.engine
import os

# Caminho para o executável do Stockfish
# Usamos dirname para garantir que ele procure na mesma pasta onde este script está salvo
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STOCKFISH_PATH = os.path.join(SCRIPT_DIR, "stockfish.exe")

def get_ai_move(fen_string, difficulty):
    try:
        # 1. Cria o tabuleiro virtual a partir do texto FEN enviado pelo Godot
        board = chess.Board(fen_string)
        
        # 2. Configura o tempo que a IA tem para pensar baseado na dificuldade
        # Dificuldade 1 = 0.1 segundos (Joga rápido, comete erros)
        # Dificuldade 3 = 1.0 segundo (Pensa muito, joga como mestre)
        time_limit = 0.1
        if difficulty == 1:
            time_limit = 0.1
        elif difficulty == 2:
            time_limit = 0.5
        elif difficulty == 3:
            time_limit = 1.0

        # 3. Inicia a comunicação com o Stockfish
        with chess.engine.SimpleEngine.popen_uci(STOCKFISH_PATH) as engine:
            # Pede para o Stockfish analisar o tabuleiro e devolver a melhor jogada
            result = engine.play(board, chess.engine.Limit(time=time_limit))
            
            # Extrai a jogada no formato de texto (ex: "e7e5")
            move_uci = result.move.uci()
            
            # Prepara a resposta em formato JSON para o Godot entender
            resposta = {
                "status": "success",
                "move_uci": move_uci
            }
            return json.dumps(resposta)

    except Exception as e:
        # Se algo der errado (ex: não achou o stockfish.exe), avisa o Godot
        erro = {
            "status": "error",
            "message": str(e)
        }
        return json.dumps(erro)

if __name__ == "__main__":
    # O Godot chama o Python passando os seguintes argumentos:
    # sys.argv[0] = caminho do próprio script
    # sys.argv[1] = FEN (O estado do tabuleiro)
    # sys.argv[2] = Ação ("get_ai_move")
    # sys.argv[3] = Dificuldade (1, 2 ou 3)

    # Verifica se o Godot enviou pelo menos o FEN e a Ação
    if len(sys.argv) < 3:
        print(json.dumps({"status": "error", "message": "Faltam argumentos."}))
        sys.exit(1)

    fen = sys.argv[1]
    action = sys.argv[2]

    if action == "get_ai_move":
        # Tenta pegar a dificuldade, se não achar, usa nível 2 como padrão
        diff = 2
        if len(sys.argv) > 3:
            try:
                diff = int(sys.argv[3])
            except ValueError:
                pass
                
        # Chama a função principal e IMPRIME o resultado (é assim que o Godot lê)
        resultado_json = get_ai_move(fen, diff)
        print(resultado_json)
        
    else:
        print(json.dumps({"status": "error", "message": "Acao desconhecida."}))