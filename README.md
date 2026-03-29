# EvoEdgeTTS Portable

EvoEdgeTTS é uma interface e API portáteis e fáceis de usar para a síntese de fala (Text-To-Speech) via Microsoft Edge. A principal vantagem deste projeto é a sua **portabilidade** e foco em usuários finais: não é necessário saber programar, usar o terminal ou instalar Python/FFmpeg manualmente. O sistema faz tudo sozinho na primeira execução!

## 🚀 Como Baixar e Instalar (Para Usuários Leigos)

Este projeto foi desenhado para ser 100% "Plug and Play". Siga os passos abaixo:

1. **Baixe o projeto**: Clique no botão verde **Code** (no topo desta página) e selecione **Download ZIP**.
2. **Extraia os arquivos**: Descompacte o arquivo ZIP em uma pasta no seu computador (ex: `Documentos` ou `Área de Trabalho`).
3. **Instalação Automática**: 
   - Dê um duplo clique no arquivo **`Instalar.bat`**.
   - Uma tela preta abrirá. O sistema baixará o Python Portátil e o FFmpeg automaticamente de forma silenciosa e configurará tudo sozinho para o seu computador. Isso pode levar alguns minutos dependendo da sua internet.
   - Aguarde aparecer a mensagem de **[SUCESSO]** e pressione qualquer tecla para fechar.
4. **Use o programa**: 
   - Dê um duplo clique no arquivo **`start.bat`**.
   - A interface do EvoEdgeTTS abrirá magicamente no seu navegador da web!

*Nota: Se você esquecer de clicar no `Instalar.bat` e abrir direto o `start.bat`, não se preocupe! O sistema é inteligente e tentará fazer a instalação automaticamente para você.*

---

## 🛠️ Para Desenvolvedores e Usuários Avançados

O EvoEdgeTTS roda um servidor FastAPI local e oferece uma UI limpa e responsiva nativamente.

### Estrutura do Projeto
- `app/api.py`: Contém a API do FastAPI e as lógicas de geração de áudio nativas usando `edge-tts`.
- `ui/index.html`: Interface visual (HTML, CSS e JS puros) que consome a API local.
- `scripts/`: Scripts PowerShell/Batch responsáveis pela automação de ambiente e inicialização.
- `Instalar.bat` e `start.bat`: Atalhos de raiz para fácil acesso.
- `output/`: Pasta onde os áudios gerados (MP3/WAV) são salvos (criada automaticamente).

### Rotas da API (Porta 8890)
Quando o sistema está rodando (via `start.bat`), os seguintes endpoints ficam disponíveis:
- Interface: `http://127.0.0.1:8890`
- Documentação Swagger: `http://127.0.0.1:8890/docs`
- Status: `GET /health`
- Listar Vozes: `GET /edge-tts/voices`
- Listar Perfis: `GET /edge-tts/profiles`
- Gerar Áudio: `POST /edge-tts` (Aceita parâmetros via Multipart Form)

### Construindo sua própria Release ZIP
Se você modificou o código e deseja gerar o seu próprio arquivo `.zip` "Plug and Play" para distribuir:
1. Abra o PowerShell.
2. Navegue até a pasta do projeto.
3. Execute o comando: `.\scripts\build_portable.ps1`
4. O arquivo pronto será gerado na pasta `dist/edge-tts-portable.zip`.

---

## ⚙️ Tecnologias Utilizadas
- **Python Embeddable** (100% isolado, não suja o PC do usuário)
- **FastAPI** & **Uvicorn**
- **edge-tts**
- **FFmpeg** & **pydub** (baixados em runtime para conversão de WAV, sem necessidade de configuração no PATH)
- UI feita puramente com **HTML/CSS/JS** modernos.

---
**Nota Legal:** Este projeto não é afiliado ou suportado pela Microsoft. A geração de áudio é baseada nas APIs de leitura em voz alta gratuitas incluídas nos serviços do navegador Edge.
