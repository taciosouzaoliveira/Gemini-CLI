# Gemini-CLI: Seu Co-piloto de IA Direto no Terminal Linux

Este projeto cria uma ferramenta de linha de comando (`gemini-cli`) que integra a poderosa API do Google Gemini diretamente ao seu terminal Linux. Em vez de alternar para um navegador, você pode gerar scripts, revisar código, entender comandos complexos e auditar sistemas em tempo real.

É uma ferramenta indispensável para Administradores de Sistemas, Engenheiros DevOps e qualquer entusiasta de Linux que busca acelerar seu aprendizado e aumentar a produtividade.

### Funcionalidades

* **Geração de Código:** Crie scripts Shell, playbooks Ansible, manifestos Kubernetes, etc., sob demanda.
* **Revisão de Código:** Envie o conteúdo de um arquivo via pipe (`|`) para receber análises, sugestões de melhoria e detecção de bugs.
* **Explicação de Comandos:** Entenda comandos complexos sem sair do terminal.
* **Auditoria de Sistema:** Analise a saída de ferramentas do sistema (`ss`, `ps`, `iptables`) para gerar relatórios claros.
* **Análise Remota:** Use pipes sobre SSH para auditar arquivos em servidores remotos de forma segura e eficiente.

### Pré-requisitos

1.  Um ambiente Linux (testado em Debian 13 "Trixie").
2.  `jq` instalado: `sudo apt update && sudo apt install jq -y`
3.  Uma **API Key** do Google Gemini. Obtenha a sua no [Google AI Studio](https://aistudio.google.com/app/apikey).

### Instalação

1.  **Configure sua API Key com Segurança:**
    Adicione sua chave de API ao seu arquivo de configuração do shell (`~/.bashrc` ou `~/.zshrc`). **Nunca coloque a chave diretamente no script!**
    ```bash
    echo 'export GEMINI_API_KEY="SUA_CHAVE_API_AQUI"' >> ~/.bashrc
    source ~/.bashrc
    ```

2.  **Crie o Script `gemini-cli`:**
    Use o comando abaixo para criar o arquivo `/usr/local/bin/gemini-cli` com o conteúdo correto.
    ```bash
    sudo tee /usr/local/bin/gemini-cli > /dev/null << 'EOF'
    #!/bin/bash

    if [ -z "$GEMINI_API_KEY" ]; then
        echo "Erro: A variável de ambiente GEMINI_API_KEY não está definida."
        exit 1
    fi

    # Usando o modelo 'gemini-pro-latest' que foi validado via API
    API_URL="[https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-latest:generateContent?key=$](https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-latest:generateContent?key=$){GEMINI_API_KEY}"

    if [ -t 0 ]; then
        PROMPT="$@"
    else
        PIPE_CONTENT=$(cat -)
        PROMPT="Contexto (fornecido via pipe):
    ---
    $PIPE_CONTENT
    ---
    Tarefa: $@
    "
    fi

    if [ -z "$PROMPT" ]; then
        echo "Uso: gemini-cli \"sua pergunta\""
        echo "Ou: cat arquivo.txt | gemini-cli \"analise este texto\""
        exit 1
    fi

    JSON_PAYLOAD=$(jq -n --arg prompt "$PROMPT" \
      '{ "contents": [ { "parts": [ { "text": $prompt } ] } ] }')

    RESPONSE=$(curl -s -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$API_URL")

    TEXT_RESPONSE=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // .error.message')

    echo -e "$TEXT_RESPONSE"
    EOF
    ```

3.  **Torne o Script Executável:**
    ```bash
    sudo chmod +x /usr/local/bin/gemini-cli
    ```
    Pronto! Agora você pode chamar `gemini-cli` de qualquer lugar do seu sistema.

### Modo de Uso

**Pergunta Simples:**
```bash
gemini-cli "Crie um comando para encontrar todos os arquivos .log com mais de 30 dias e apagá-los."
```

**Revisão de um Script Local:**
```bash
cat meu_script.sh | gemini-cli "Revise este script em busca de erros e sugira melhorias."
```

**Análise da Saída de um Comando:**
```bash
ss -tuln | gemini-cli "Analise esta saída e me diga quais serviços estão rodando em quais portas."
```

**Análise Remota de um Arquivo de Configuração (via SSH):**
```bash
ssh user@servidor-remoto 'cat /etc/nginx/nginx.conf' | gemini-cli "Audite este arquivo de configuração NGINX em busca de falhas de segurança."
```

### A Jornada do Troubleshooting: Por que não funcionava?

Durante a criação desta ferramenta, enfrentei um erro persistente `404 NOT_FOUND` da API do Google, com a mensagem `models/gemini-pro is not found`. O processo para resolver foi um ótimo exercício de diagnóstico:

1.  **Isolando o Problema:** A primeira suspeita era o script. Para confirmar, usei `curl` para fazer uma chamada direta à API, removendo o script da equação.
    ```bash
    curl -H 'Content-Type: application/json' ... "URL_DA_API"
    ```
    O `curl` retornou o mesmo erro! Isso provou que o script estava correto e o problema estava na comunicação com a API (permissões ou endpoint errado).

2.  **Seguindo a Pista da API:** A própria mensagem de erro sugeria a solução: `Call ListModels to see the list of available models`. Executei o comando para listar os modelos que a minha chave de API específica tinha permissão para usar:
    ```bash
    curl -s "[https://generativelanguage.googleapis.com/v1beta/models?key=$GEMINI_API_KEY](https://generativelanguage.googleapis.com/v1beta/models?key=$GEMINI_API_KEY)" | jq
    ```

3.  **A Revelação:** A saída deste comando mostrou que o modelo `gemini-pro` não estava na minha lista. No entanto, um modelo chamado `gemini-pro-latest` estava disponível e suportava o método `generateContent`.

4.  **A Correção Final:** A solução foi simples: editar o script `gemini-cli` e substituir o nome do modelo na `API_URL` de `gemini-pro` para `gemini-pro-latest`. Após essa alteração, tudo funcionou perfeitamente.

Este processo destaca a importância de ler as mensagens de erro com atenção e usar ferramentas básicas como `curl` para isolar variáveis e diagnosticar problemas complexos.
