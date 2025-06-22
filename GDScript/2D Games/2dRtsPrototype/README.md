# Prompt pro ChatGPT:

Contexto geral
— Godot 4.5, GDScript 2D.
— O jogo tem duas camadas principais:
Mapa global: você escolhe um ponto de interesse (Area2D) clicando, mas só entra se seu “avatar” estiver sobre ele. Ao entrar, troca para a cena de dungeon correspondente.
Dungeon (local): antes de entrar, abre um menu de party-select (você escolhe quais personagens levar). Dentro da dungeon, combate em tempo real com seu grupo(PCs) contra inimigos (NPCs).

Detalhes do combate
Cada NPC tem:
Area2D de visão (cone/círculo) + RayCast2D para linha de visão.
NavigationAgent2D para percorrer o tilemap até o alvo.
Area2D de ataque: ao entrar, dá dano (aqui só um print para testar).
Cada PC tem:
Movimento RTS via SelectionLayer + clique direito → NavigationAgent2D.
Area2D de próprio ataque (ataque automático a NPCs que entrarem).

Fluxo de jogo
WorldMap.tscn: Node2D com vários Area2D que, ao clicar e estando seu avatar sobre ela, chama change_scene() para a dungeon.
Party Select: menu popup antes de entrar na dungeon.
Dungeon: instanciar PCs (grupo escolhido) e NPCs; ativar sistema de seleção + movimento RTS para PCs; IA de patrulha, detecção, perseguição e ataque para NPCs.
Saída: em cada dungeon há um Area2D que retorna ao WorldMap.

Perguntas
Quais arquivos e cenas criar primeiro, e em que ordem?
Qual a estrutura de nós ideal para WorldMap, PartySelect e Dungeon?
Exemplos de scripts para:
WorldMap (clique em Area2D + troca de cena).
SelectionLayer + Unit.gd para movimento RTS.
NPC AI (idle ou patrol → detect → chase → attack → idle).
Como organizar tudo em um projeto escalável, com pastas, singletons de estado e comunicação de cenas?

Requerimento(s)
Codigo limpo sem usar \ para if-else, evitar usar codigo de versões antigas do Godot, deixar o uso do codigo GDScript descritivo, sem usar variaveis obscuras como b, bvp, etc. Deixar elas descritiveis com os requerimentos.
