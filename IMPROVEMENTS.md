# 💡 Melhorias Futuras

Documento com sugestões de melhorias futuras para o projeto dotfiles.

---

## 🚀 Melhorias Implementadas

Todas as melhorias de alta e média prioridade já foram implementadas:

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
