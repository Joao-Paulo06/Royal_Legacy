import chess
import chess.engine
import sys
import json
import os

# Caminho para o executável do Stockfish (pode variar)
# No Ubuntu, o apt-get instala como 'stockfish'
STOCKFISH_PATH = "stockfish"

def get_stockfish_move(fen, difficulty):
    """
    Obtém o melhor movimento do Stockfish.
    A dificuldade é mapeada para a profundidade (depth) do motor.
    """
    try:
        board = chess.Board(fen)
        engine = chess.engine.SimpleEngine.popen_uci(STOCKFISH_PATH)
        
        # Mapeamento de dificuldade para profundidade (exemplo)
        # 1: depth 5, 2: depth 8, 3: depth 12, 4: depth 16, 5: depth 20
        depth_map = {
            1: 5,
            2: 8,
            3: 12,
            4: 16,
            5: 20
        }
        
        limit = chess.engine.Limit(depth=depth_map.get(difficulty, 12))
        
        result = engine.play(board, limit)
        engine.quit()
        
        return {
            "status": "success",
            "move_uci": result.move.uci()
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao obter movimento do Stockfish: {e}"
        }

def validate_move(fen, move_uci):
    """
    Verifica se um movimento é legal.
    """
    try:
        board = chess.Board(fen)
        move = chess.Move.from_uci(move_uci)
        
        is_legal = move in board.legal_moves
        
        return {
            "status": "success",
            "is_legal": is_legal
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao validar movimento: {e}"
        }

def apply_move(fen, move_uci):
    """
    Aplica um movimento e retorna o novo FEN.
    """
    try:
        board = chess.Board(fen)
        move = chess.Move.from_uci(move_uci)
        
        if move not in board.legal_moves:
            return {
                "status": "error",
                "message": f"Movimento ilegal: {move_uci}"
            }
            
        board.push(move)
        
        return {
            "status": "success",
            "new_fen": board.fen()
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao aplicar movimento: {e}"
        }

def get_game_state(fen):
    """
    Verifica o estado do jogo (xeque, xeque-mate, empate).
    """
    try:
        board = chess.Board(fen)
        
        state = "playing"
        winner = None
        
        if board.is_checkmate():
            state = "checkmate"
            winner = "branca" if board.turn == chess.BLACK else "preta"
        elif board.is_stalemate():
            state = "stalemate"
        elif board.is_insufficient_material():
            state = "draw_insufficient_material"
        elif board.is_fivefold_repetition():
            state = "draw_repetition"
        elif board.is_seventyfive_moves():
            state = "draw_seventyfive_moves"
        elif board.is_check():
            state = "check"
        
        return {
            "status": "success",
            "state": state,
            "is_check": board.is_check(),
            "is_checkmate": board.is_checkmate(),
            "is_stalemate": board.is_stalemate(),
            "winner": winner
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro ao obter estado do jogo: {e}"
        }

def main():
    if len(sys.argv) < 3:
        print(json.dumps({"status": "error", "message": "Argumentos insuficientes. Uso: <FEN> <action> [args...]"}), file=sys.stderr)
        sys.exit(1)

    fen = sys.argv[1]
    action = sys.argv[2]
    
    result = {"status": "error", "message": "Ação desconhecida."}

    if action == "get_ai_move":
        try:
            difficulty = int(sys.argv[3])
            result = get_stockfish_move(fen, difficulty)
        except IndexError:
            result = {"status": "error", "message": "Dificuldade não fornecida para get_ai_move."}
        except ValueError:
            result = {"status": "error", "message": "Dificuldade deve ser um número inteiro."}
            
    elif action == "validate_move":
        try:
            move_uci = sys.argv[3]
            result = validate_move(fen, move_uci)
        except IndexError:
            result = {"status": "error", "message": "Movimento não fornecido para validate_move."}
            
    elif action == "apply_move":
        try:
            move_uci = sys.argv[3]
            result = apply_move(fen, move_uci)
        except IndexError:
            result = {"status": "error", "message": "Movimento não fornecido para apply_move."}
            
    elif action == "get_game_state":
        result = get_game_state(fen)

    print(json.dumps(result))

if __name__ == "__main__":
    # Adiciona o diretório do venv ao PATH para que o script encontre o python-chess
    # Isso é necessário se o script for executado diretamente sem ativar o venv
    venv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../venv_chess/lib/python3.11/site-packages")
    sys.path.append(venv_path)
    
    main()
