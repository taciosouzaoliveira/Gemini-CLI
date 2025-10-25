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

Este comando baixa o script diretamente para `/usr/local/bin` e o torna executável.

```bash
sudo curl -o /usr/local/bin/gemini-cli [https://raw.githubusercontent.com/taciosouzaoliveira/SEU-REPOSITORIO/main/gemini-cli](https://raw.githubusercontent.com/taciosouzaoliveira/SEU-REPOSITORIO/main/gemini-cli)
sudo chmod +x /usr/local/bin/gemini-cli
```
*(Lembre-se de substituir `SEU-REPOSITORIO` pelo nome real do seu repositório)*

**Opção 2: Via `git clone` (Para desenvolvedores)**

```bash
git clone [https://github.com/taciosouzaoliveira/SEU-REPOSITORIO.git](https://github.com/taciosouzaoliveira/SEU-REPOSITORIO.git)
cd SEU-REPOSITORIO
sudo cp gemini-cli /usr/local/bin/
sudo chmod +x /usr/local/bin/gemini-cli
```

### Configuração Final

Não se esqueça de configurar sua chave de API no seu `~/.bashrc` ou `~/.zshrc`:

```bash
echo 'export GEMINI_API_KEY="SUA_CHAVE_API_AQUI"' >> ~/.bashrc
source ~/.bashrc

