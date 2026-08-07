---
title: Consulting
---

## Nix Infrastructure & Embedded Systems Consulting

Flaky builds, unreproducible environments, and slow CI pipelines cost your team time every day. I fix that by making your entire stack declarative, versionable, and auditable with Nix.

I specialize in reproducible build infrastructure, embedded Linux, and systems programming in Rust. I maintain packages in nixpkgs, contribute to the Linux kernel, and have introduced Nix across firmware and software teams in production environments.

## What I Offer

### Declarative Infrastructure with Nix

Most build systems accumulate hidden state over time. Nix eliminates that by making every dependency explicit and every build reproducible from source. I have used this in production across firmware, kiosk systems, and CI/CD pipelines.

**I can help you:**
- Design and implement Nix-based CI/CD pipelines for reproducible builds across environments
- Migrate legacy build systems to declarative Nix configurations
- Write custom NixOS modules for your specific infrastructure needs
- Build containerized and VM-based testing environments that spin up in seconds
- Create development environments that work identically for every team member

### Automated Testing & Quality Assurance

Testing embedded and Linux-based systems is hard because the environment matters as much as the code.
I build test infrastructure that runs your software in environments that mirror production exactly, using NixOS VM orchestration and hardware-in-the-loop setups.

**Services include:**
- Integration testing across multiple services with automated orchestration
- Kiosk and embedded system test automation
- Continuous testing pipelines integrated with your existing CI tools
- Test environments provisioned from the same Nix configuration as production
- QEMU-based virtual hardware testbeds for testing firmware and embedded software without physical devices

### Secure Embedded Systems

Security in embedded systems has to be built into the hardware, not bolted on afterward. I implement trusted execution environments and hardware-backed security primitives for devices where compromise is not an option.

**Expertise in:**
- OP-TEE trusted application development and integration
- Hardware-backed cryptographic operations and secure key storage
- ARM TrustZone implementation for secure/non-secure world isolation
- Secure boot implementation for embedded Linux targets

### Systems Programming & Performance

When correctness and performance are non-negotiable, I write systems code in Rust. I also work at the kernel level when the problem lives there, including driver development and platform support.

**I specialize in:**
- Rust development for systems where reliability and memory safety are critical
- Linux kernel driver development and platform support (current maintainer of Dell PC platform support)
- Memory-safe refactoring of critical C codebases
- Cross-compilation for embedded targets including aarch64

## Who I Work With

I work best with teams that have hard infrastructure problems and the technical appetite to solve them properly.

- **Platform and DevOps teams** struggling with unreproducible builds, slow CI, or brittle deployment pipelines
- **Embedded and firmware teams** building secure IoT devices, kiosks, or edge computing platforms
- **Security-focused teams** requiring trusted execution environments and hardware-level security primitives
- **Product teams** dealing with flaky tests, complex multi-service architectures, or environment drift between development and production

## Engagement Models

**Consulting Projects** -- Fixed-scope work with defined deliverables, typically 2 to 8 weeks. Ideal for migrations, proof-of-concepts, or building specific infrastructure from scratch.

**Retainer Arrangements** -- Ongoing access to specialized expertise for teams that need regular support, code review, or architectural guidance.

**Architecture Review** -- A focused engagement to evaluate your current systems and deliver concrete recommendations with an implementation roadmap.

## Why Work With Me

Nix, Rust, OP-TEE, and Linux kernel development is a rare combination. Most engineers know one or two of these deeply. I use all of them together in production, which means I can see problems that specialists in any single area would miss.

I also focus on leaving teams better than I found them. Every engagement includes knowledge transfer, documentation, and clear explanations of architectural decisions. You should understand what I built and why, not just that it works.

## Let's Talk

Have a build problem worth solving? Let's talk: [consulting@lyndeno.ca](mailto:consulting@lyndeno.ca)
