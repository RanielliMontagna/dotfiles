# 💡 Melhorias Futuras

Documento com sugestões de melhorias futuras para o projeto dotfiles.

---

## 🚀 Melhorias Implementadas

Melhorias de alta e média prioridade já implementadas:

- ✅ Timeouts em downloads com retry automático
- ✅ Verificação de conectividade antes de iniciar
- ✅ Renovação automática do sudo durante instalações longas
- ✅ Padronização de funções comuns (`common.sh`)
- ✅ Cache de downloads
- ✅ Verificação de espaço em disco
- ✅ Indicadores de progresso
- ✅ Otimização de apt-get (update centralizado)
- ✅ Validação de arquitetura
- ✅ Validação de checksums (quando disponível)
- ✅ **Personalização Visual do Sistema (Tema Dark)** - Script `00-customization.sh` implementado

---

## 🔥 Melhorias de Alta Prioridade

### 1. ✅ Personalização Visual do Sistema (Tema Dark) - IMPLEMENTADO

**Objetivo**: Criar um sistema mais dark que combine com o estilo pessoal e deixe a interface visualmente atraente.

#### 🎨 Temas e Aparência

**Status**: ✅ **IMPLEMENTADO**

**Melhorias implementadas**:

- ✅ **Temas GTK**: Usa tema dark nativo do Zorin OS (via `color-scheme: prefer-dark`)
- ✅ **Ícones**: Usa ícones nativos do Zorin OS (modo dark automático)
- ✅ **Fontes**: Instala e configura Inter e JetBrains Mono system-wide
- ✅ **Wallpaper**: Configura automaticamente wallpaper dark de `assets/wallpapers/background.jpg`
- ✅ **Cores de acento**: Configura color-scheme prefer-dark para aplicações GTK
- ✅ **Zorin OS específico**: Configura temas específicos do Zorin OS usando modo dark nativo
- ✅ **Configuração de energia**: Desabilita hibernação automática (suspend/hibernate) tanto em AC quanto bateria

#### 🖥️ Terminal e Shell

**Status**: ✅ **IMPLEMENTADO**

**Melhorias implementadas**:

- ✅ Perfil de cores dark personalizado no GNOME Terminal (tema Nord)
- ✅ Configuração automática de paleta de cores dark
- ✅ Fonte JetBrains Mono configurada no terminal
- ✅ **Starship prompt** - Modern, fast, and customizable prompt (written in Rust) instead of Powerlevel10k
- ⚠️ Transparência/blur: Não implementado (requer extensões adicionais)

#### 🎭 Extensões GNOME (Zorin OS)

**Status**: ✅ **IMPLEMENTADO**

**Melhorias implementadas**:

- ✅ **Extension Manager**: Instala automaticamente `gnome-shell-extension-manager`
- ✅ **Clipboard Indicator**: Instalação e ativação automática (com re-ativação forçada)
- ✅ **Blur My Shell**: Instalação e ativação automática (efeitos de blur)
- ✅ **Caffeine**: Instalação e ativação automática (previne bloqueio de tela)
- ✅ **Dash to Panel**: Instalação e ativação automática (combina dash e top panel)
- ✅ **Vitals**: Instalação e ativação automática com configuração completa (temperatura, CPU, memória, rede, bateria)
- ✅ **Download automático via API**: Usa extensions.gnome.org API para baixar versões compatíveis
- ✅ **Re-ativação forçada**: Re-habilita extensões após instalação para garantir funcionamento
- ✅ **Verificação de compatibilidade**: Verifica versão do GNOME Shell antes de instalar
- ✅ **Permissões corrigidas automaticamente**: Garante que extensões tenham permissões corretas

#### 🎬 Animações e Efeitos

**Status**: ⚠️ **NÃO IMPLEMENTADO**

**Melhorias pendentes**:

- ⏳ Configurar velocidades de animação (acelerar/reduzir)
- ⏳ Efeitos de transição suaves entre workspaces
- ⏳ Configurar blur e transparência em menus e painéis
- ⏳ Efeitos visuais em janelas (sombra, bordas arredondadas)

**Nota**: Estas melhorias requerem extensões GNOME específicas (como Blur My Shell) que podem ser instaladas manualmente via Extension Manager.

#### 🔔 Tela de Login (GDM)

**Status**: ⚠️ **NÃO IMPLEMENTADO**

**Melhorias pendentes**:

- ⏳ Configurar wallpaper da tela de login (lock screen)
- ⏳ Aplicar tema dark no GDM
- ⏳ Customizar aparência do seletor de usuário

**Nota**: Configuração do GDM requer permissões de sistema avançadas e pode variar entre versões do GNOME/Zorin.

---

## 💡 Melhorias Futuras (Nice to Have)

### 1. ✅ Seleção Interativa de Componentes - IMPLEMENTADO

**Melhorias implementadas**:

- ✅ Sistema de seleção interativa no início do bootstrap.sh
- ✅ Permite marcar/desmarcar scripts individuais para instalação
- ✅ Valida seleções e permite editar antes de confirmar
- ✅ Mostra resumo antes de iniciar instalação

### 2. Tratamento de Erros Melhorado

**Melhorias**:

- Log de erros em arquivo temporário
- Opção de modo verbose para debugging (`--verbose`)
- Continuar instalação mesmo se um item falhar (com resumo final)

### 3. Paralelização de Instalações

**Melhorias**:

- Instalar pacotes apt independentes em paralelo quando possível
- Aplicar apenas para pacotes pequenos e independentes
- Cuidado com dependências!

### 4. Testes Automatizados

**Melhorias**:

- Expandir `test.sh` para testar idempotência automaticamente
- Testes em container Docker
- Validação de sintaxe bash com `shellcheck`

---

**Nota**: Este documento serve como backlog de ideias. Priorize com base em necessidade real.
