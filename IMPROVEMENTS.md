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

---

## 🔥 Melhorias de Alta Prioridade

### 1. Personalização Visual do Sistema (Tema Dark)

**Objetivo**: Criar um sistema mais dark que combine com o estilo pessoal e deixe a interface visualmente atraente.

#### 🎨 Temas e Aparência

**Melhorias**:

- **Temas GTK**: Instalar e configurar tema dark personalizado (ex: Adwaita Dark, Arc Dark, Dracula, Nord, One Dark)
- **Ícones**: Configurar conjunto de ícones dark (ex: Papirus Dark, Numix Circle Dark, Tela Dark)
- **Fontes**: Configurar fontes system-wide (ex: Inter, Fira Sans, SF Pro, JetBrains Mono)
- **Wallpaper**: Definir background padrão com tema dark (com opção de slideshow automático)
- **Cores de acento**: Configurar cor de destaque do sistema (paleta consistente)

#### 🖥️ Terminal e Shell

**Melhorias**:

- Perfil de cores dark personalizado no terminal (GNOME Terminal/Tilix)
- Esquema de cores consistente entre terminal e Powerlevel10k
- Configurar transparência/blur no terminal (se suportado)
- Cores de syntax highlighting consistentes em todos os editores

#### 🎭 Extensões GNOME (Zorin OS)

**Melhorias**:

- **Dash to Dock/Dock**: Configurar dock customizado com tema dark
- **Blur My Shell**: Aplicar efeitos de blur e transparência
- **User Themes**: Permitir uso de temas customizados
- **Clipboard Indicator**: Indicador de área de transferência
- **GSConnect**: Integração com Android
- **AppIndicator**: Suporte completo a ícones de sistema
- **Caffeine**: Desabilitar suspensão durante uso
- **Coverflow Alt-Tab**: Visualização melhorada ao alternar janelas
- **Just Perfection**: Controles avançados de UI do GNOME
- **Dash to Panel**: Transformar dock em painel estilo Windows/macOS

#### 🎬 Animações e Efeitos

**Melhorias**:

- Configurar velocidades de animação (acelerar/reduzir)
- Efeitos de transição suaves entre workspaces
- Configurar blur e transparência em menus e painéis
- Efeitos visuais em janelas (sombra, bordas arredondadas)

#### 🔔 Tela de Login (GDM)

**Melhorias**:

- Configurar wallpaper da tela de login (lock screen)
- Aplicar tema dark no GDM
- Customizar aparência do seletor de usuário

---

## 💡 Melhorias Futuras (Nice to Have)

### 1. Tratamento de Erros Melhorado

**Melhorias**:

- Log de erros em arquivo temporário
- Opção de modo verbose para debugging (`--verbose`)
- Continuar instalação mesmo se um item falhar (com resumo final)

### 2. Paralelização de Instalações

**Melhorias**:

- Instalar pacotes apt independentes em paralelo quando possível
- Aplicar apenas para pacotes pequenos e independentes
- Cuidado com dependências!

### 3. Testes Automatizados

**Melhorias**:

- Expandir `test.sh` para testar idempotência automaticamente
- Testes em container Docker
- Validação de sintaxe bash com `shellcheck`

---

**Nota**: Este documento serve como backlog de ideias. Priorize com base em necessidade real.
