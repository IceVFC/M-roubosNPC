# M-roubosNPC
Script de assaltos a NPC(americanos) FiveM

---------------------------------------------------

# Script m-roubosnpc (Assalto a NPCs) para QBCore

Um script FiveM robusto e imersivo que permite aos jogadores assaltar NPCs aleatórios na cidade, com um sistema de reações dinâmicas e recompensas variadas. Projetado para servidores QBCore, focado em proporcionar uma experiência de assalto perigosa e recompensadora.

## Funcionalidades

  * **Assalto Dinâmico:** Inicia automaticamente um assalto a qualquer NPC civil ao apontar uma arma de fogo ou arma branca para ele, dentro de uma distância configurável.
  * **Animações Realistas:** O NPC assaltado levanta as mãos durante o processo.
  * **Barra de Progresso:** Utiliza o `QBCore.Functions.Progressbar` para um assalto com duração aleatória (5-10 segundos).
  * **Sistema de Loot Variado:**
      * **Dinheiro Sujo:** Quantidades aleatórias com probabilidades configuráveis (de 10 a 1200).
      * **Itens Diversos:** Uma vasta gama de itens, desde consumíveis e materiais a objetos de valor, com quantidades e probabilidades personalizáveis.
      * **Armas Raras:** Pequena chance de obter armas específicas, limitado a uma por assalto.
  * **Reações Perigosas de NPCs:**
      * **NPCs Hostis:** Probabilidade configurável de NPCs próximos reagirem ao assalto, spawnando e atacando o jogador com diferentes tipos de armas (facas, bastões, pistolas, SMGs).
      * **Ataques de Cães:** Probabilidade de cães selvagens atacarem o jogador, aumentando o perigo.
      * **Nível de Procurado:** As reações de NPCs e cães podem resultar num nível de procurado (wanted level) para o jogador.
  * **Notificações Detalhadas:** Informa o jogador sobre os itens e a quantidade de dinheiro roubados através de notificações do QBCore.
  * **Cancelamento Automático:** O assalto é cancelado se o jogador parar de apontar, guardar a arma, ou se o NPC se mover para fora do alcance.
  * **Otimizado:** Utiliza `Citizen.Wait(0)` durante a interação para máxima responsividade e limpa os NPCs reagentes para evitar sobrecarga do servidor.

## Requisitos

  * [QBCore Framework](https://github.com/qbcore-framework/qb-core) (essencial para inventário, dinheiro sujo, notificações e progressbar)

## Instalação

1.  **Descarregar o Recurso:** Descarrega este repositório ou o pacote do script.

2.  **Extrair para a Pasta de Recursos:** Coloca a pasta `m-roubosnpc` na tua pasta de recursos do FiveM (`resources/`).

3.  **Adicionar ao `server.cfg`:** Abre o teu `server.cfg` (no diretório principal do teu servidor FiveM) e adiciona a seguinte linha, **garantindo que esteja APÓS `ensure qb-core`**:

    ```cfg
    ensure qb-core
    ensure m-roubosnpc
    ```

4.  **Reiniciar o Servidor:** Reinicia o teu servidor FiveM.

## Configuração (`config.lua`)

Todas as configurações podem ser facilmente ajustadas no ficheiro `config.lua`.

  * `Config.InteractionDistance`: Distância máxima para iniciar o assalto (padrão: `2.0` metros).
  * `Config.RobberyTime`: Duração mínima e máxima do progressbar do assalto (padrão: `{ min = 5, max = 10 }` segundos).
  * `Config.NPCReaction`: Define se NPCs e cães podem reagir, a chance de reação, o raio de alcance e os modelos/armas dos NPCs reagentes, bem como os modelos de cães e a quantidade.
  * `Config.MoneyLoot`: Define o range de dinheiro sujo e as probabilidades para diferentes quantidades.
  * `Config.ItemLoot`: Lista detalhada de todos os itens que podem ser roubados, incluindo `minQty`, `maxQty`, `chance` e um booleano `isWeapon` para identificar armas. Certifica-te de que os `item` nomes correspondem aos teus itens no QBCore.

## Utilização

1.  **Entra no jogo.**
2.  **Equipa uma arma:** Pega em qualquer arma de fogo ou arma branca (faca, bastão, etc.).
3.  **Encontra um NPC:** Aproxima-te de um NPC civil (não-jogador).
4.  **Aponta a arma:** Aponta a tua arma diretamente para o NPC.
5.  **Início do Assalto:** O NPC render-se-á (mãos no ar) e uma barra de progresso aparecerá automaticamente no teu ecrã.
6.  **Conclusão/Cancelamento:**
      * **Sucesso:** Se o progressbar completar, receberás as recompensas no teu inventário e através de uma notificação detalhada.
      * **Cancelamento:** Se parares de apontar a arma ou guardares a arma antes do fim do progressbar, o assalto será cancelado.
7.  **Esteja Preparado:** Fica atento a NPCs ou cães que possam reagir e atacar-te durante ou após o assalto\!

## Solução de Problemas

  * **`SCRIPT ERROR: ... attempt to index a nil value (global 'QBCore')`**: Isto significa que o QBCore não foi carregado antes deste script.
      * **Solução:** Garante que `ensure qb-core` está no teu `server.cfg` **antes** de `ensure m-roubosnpc`. Reinicia o servidor completo após a alteração.
  * **NPCs não reagem / Não recebo loot / Outros problemas:**
      * Verifica a consola do cliente (F8) e do servidor para quaisquer mensagens de erro.
      * Confere os valores em `config.lua`, especialmente as `Chance` de reações e as `Probabilities` de loot, para garantir que não estão a `0` ou valores muito baixos.
      * Certifica-te de que os nomes dos itens e modelos dos peds em `config.lua` correspondem aos teus no QBCore e FiveM.

## Créditos

  * **Autor:** [José Montanelas]
  * **Framework:** QBCore Framework

-----
