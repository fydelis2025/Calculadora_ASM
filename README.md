# 🧮 Calculadora Gráfica em Assembly x64 — Windows API

<div align="center">

![GitHub Repo Size](https://img.shields.io/github/repo-size/seu-usuario/seu-repositorio.svg)
![NASM](https://img.shields.io/badge/NASM-2.15+-orange.svg)
![MinGW-w64](https://img.shields.io/badge/MinGW-w64-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2F11-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

> Calculadora de interface gráfica nativa para Windows, desenvolvida puramente em **Assembly x64** com chamadas diretas à **Windows API**. Sem dependências de alto nível, sem CRT, sem bibliotecas extras.

</div>

---

## ✨ Recursos

- 🪟 **Janela nativa do Windows** criada com `RegisterClassExA` + `CreateWindowExA`
- 🧮 **Operações básicas**: adição, subtração, multiplicação e divisão
- 🔢 **Visor alinhado à direita** com controle `EDIT` (somente leitura)
- 🎹 **Interface completa com botões**: dígitos 0–9, ponto decimal, operadores, `C` (limpar) e `=`
- ⚡ **Código 100% assembly x64** — sem runtime C, sem dependências externas
- 📦 Executável leve e independente (~15KB)

---

## 🖼️ Captura de Tela



---

## 🛠️ Pré-requisitos

| Ferramenta | Requisito |
|---|---|
| Montador | **NASM** ≥ 2.15 (`nasm -f win64`) |
| Compilador/Linker | **MinGW-w64** (GCC para Windows x64) |
| Sistema Operacional | Windows 10 ou 11 (x64) |

> 💡 Recomendado: **Strawberry Perl** (inclui MinGW) ou **Qt Tools** (`mingw1310_64`).

---

## 📂 Estrutura do Projeto
