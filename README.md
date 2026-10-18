# Gemini-CLI: Seu Co-piloto de IA Direto no Terminal Linux

Este projeto cria uma ferramenta de linha de comando (`gemini-cli`) que integra a poderosa API do Google Gemini diretamente ao seu terminal Linux. Em vez de alternar para um navegador, você pode gerar scripts, revisar código, entender comandos complexos e auditar sistemas em tempo real.

### O script

O código está em [`gemini-cli`](gemini-cli). Destaques:

- **A chave da API vai no cabeçalho `x-goog-api-key`**, não na URL, então não aparece na lista de processos (`ps`) nem em logs.
- O texto é montado com `jq`, então aspas, quebras de linha e caracteres especiais do prompt não quebram o JSON.
- Aceita contexto por pipe: `cat log.txt | gemini-cli "resuma os erros"`.
- Confere as dependências (`curl`, `jq`) e a variável `GEMINI_API_KEY` antes de chamar a API.
- Modelo configurável por `GEMINI_MODEL` (padrão `gemini-2.5-flash`).

```bash
gemini-cli "explique o comando ss -tulpn"
journalctl -p err -n 50 | gemini-cli "o que está falhando e como corrigir?"
GEMINI_MODEL=gemini-2.5-pro gemini-cli "revise este script" < deploy.sh
```

### Instalação

Você pode instalar esta ferramenta de duas maneiras:

**Opção 1: Via `curl` (Recomendado para uso rápido)**

Este comando baixa o script diretamente do seu repositório para `/usr/local/bin` e o torna executável.

```bash
sudo curl -o /usr/local/bin/gemini-cli https://raw.githubusercontent.com/taciosouzaoliveira/Gemini-CLI/main/gemini-cli
sudo chmod +x /usr/local/bin/gemini-cli
```

**Opção 2: Via `git clone` (Para desenvolvedores)**

```bash
git clone https://github.com/taciosouzaoliveira/Gemini-CLI.git
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
