import sys
import json
import chess
import chess.engine


# ... (Mantenha as suas configurações de caminho do Stockfish iguais) ...

def get_ai_move(fen, dificuldade_str):
    # Ajuste o caminho para onde o seu Stockfish está instalado
    caminho_stockfish = "caminho/para/o/seu/stockfish.exe"

    board = chess.Board(fen)

    try:
        with chess.engine.SimpleEngine.popen_uci(caminho_stockfish) as engine:

            # ======== A MÁGICA DA DIFICULDADE ========
            dificuldade = int(dificuldade_str)

            if dificuldade == 1:
                # FÁCIL: IA "burrinha". Erra lances óbvios e pensa pouco.
                engine.configure({"Skill Level": 2})
                limite = chess.engine.Limit(depth=3, time=0.1)

            elif dificuldade == 2:
                # MÉDIO: Jogador de clube amador. Dá trabalho, mas comete deslizes.
                engine.configure({"Skill Level": 10})
                limite = chess.engine.Limit(depth=8, time=0.5)

            else:
                # DIFÍCIL (3): Grande Mestre. Implacável e pensa muitos lances à frente.
                engine.configure({"Skill Level": 20})
                limite = chess.engine.Limit(depth=15, time=1.5)
            # =========================================

            result = engine.play(board, limite)

            print(json.dumps({
                "status": "success",
                "move_uci": result.move.uci()
            }))

    except Exception as e:
        print(json.dumps({
            "status": "error",
            "message": str(e)
        }))


# Lógica para receber os comandos da Godot
if __name__ == "__main__":
    if len(sys.argv) > 3:
        comando = sys.argv[2]
        if comando == "get_ai_move":
            fen_board = sys.argv[1]
            nivel_dificuldade = sys.argv[3]  # Recebendo o "1", "2" ou "3" da Godot
            get_ai_move(fen_board, nivel_dificuldade)