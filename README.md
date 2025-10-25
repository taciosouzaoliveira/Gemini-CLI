# Gemini-CLI: Seu Co-piloto de IA Direto no Terminal Linux

Este projeto cria uma ferramenta de linha de comando (`gemini-cli`) que integra a poderosa API do Google Gemini diretamente ao seu terminal Linux. Em vez de alternar para um navegador, você pode gerar scripts, revisar código, entender comandos complexos e auditar sistemas em tempo real.

### Código-Fonte (`gemini-cli`)

Abaixo está o conteúdo completo do script para referência.

```bash
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
```

### Instalação

Você pode instalar esta ferramenta de duas maneiras:

**Opção 1: Via `curl` (Recomendado para uso rápido)**

Este comando baixa o script diretamente do seu repositório para `/usr/local/bin` e o torna executável.

```bash
sudo curl -o /usr/local/bin/gemini-cli [https://raw.githubusercontent.com/taciosouzaoliveira/Gemini-CLI/main/gemini-cli](https://raw.githubusercontent.com/taciosouzaoliveira/Gemini-CLI/main/gemini-cli)
sudo chmod +x /usr/local/bin/gemini-cli
```

**Opção 2: Via `git clone` (Para desenvolvedores)**

```bash
git clone [https://github.com/taciosouzaoliveira/Gemini-CLI.git](https://github.com/taciosouzaoliveira/Gemini-CLI.git)
cd Gemini-CLI
sudo cp gemini-cli /usr/local/bin/
sudo chmod +x /usr/local/bin/gemini-cli
```

### Configuração Final

Não se esqueça de configurar sua chave de API no seu `~/.bashrc` ou `~/.zshrc`:

```bash
echo 'export GEMINI_API_KEY="SUA_CHAVE_API_AQUI"' >> ~/.bashrc
source ~/.bashrc
```

### A Jornada do Troubleshooting: Por que não funcionava?

Durante a criação desta ferramenta, enfrentei um erro persistente `404 NOT_FOUND` da API do Google. O processo para resolver foi um ótimo exercício de diagnóstico:

1.  **Isolando o Problema:** Usei `curl` para fazer uma chamada direta à API, o que provou que o erro não estava no script, mas na requisição.

2.  **Seguindo a Pista da API:** A própria mensagem de erro sugeria a solução: `Call ListModels`. Executei o comando para listar os modelos que a minha chave de API específica tinha permissão para usar.

3.  **A Revelação:** A saída deste comando mostrou que o modelo `gemini-pro` não estava na minha lista, mas sim o `gemini-pro-latest`.

4.  **A Correção Final:** A solução foi editar a variável `API_URL` no script para usar o nome correto do modelo. Após essa alteração, tudo funcionou perfeitamente.
