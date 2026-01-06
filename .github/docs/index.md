# Hydra-Yaci Documentation

Welcome to the Hydra-Yaci documentation! This project enables the use of Hydra protocols in a Yaci DevKit local network, providing a complete solution for testing and developing payment channel applications on Cardano.

## 🚀 Quick Links

- [Getting Started](getting-started.md)
- [Installation Guide](installation.md)
- [Configuration Guide](configuration.md)
- [Usage Guide](usage.md)
- [Troubleshooting](troubleshooting.md)
- [API Reference](api-reference.md)

## 📖 Overview

**Hydra-Yaci** is a payment channel application that combines:

- **Yaci DevKit**: A local Cardano development network
- **Hydra Head Protocol**: Cardano's Layer 2 scaling solution
- **Docker**: Containerized Hydra nodes for easy deployment

This project provides a complete development environment for building and testing Hydra-based applications locally, with support for:

- Multi-party Hydra heads (Alice, Bob, Carol)
- Automated key generation
- Wallet funding and management
- WebSocket API for real-time interactions
- Monitoring with Prometheus and Grafana

## 🎯 Key Features

### Developer-Friendly Setup
- Automated prerequisite checking
- One-command setup and initialization
- Docker-based Hydra nodes for cross-platform compatibility
- Comprehensive example scripts

### Complete Hydra Integration
- Hydra node Docker integration (v1.2.0)
- Cardano CLI wrappers
- Automated key generation for all participants
- Script publishing utilities

### Monitoring & Debugging
- WebSocket debugging support
- Prometheus metrics
- Grafana dashboards
- Hydra TUI (Terminal User Interface)

### Example Applications
- Status checking
- Address generation
- Wallet funding
- Head opening/closing
- Payment transactions

## 🏗️ Project Structure

```
hydra-yaci/
├── .github/
│   └── docs/              # Documentation (you are here)
├── config/
│   └── hydra/             # Hydra protocol parameters
├── examples/              # Example scripts
│   ├── check-yaci.js
│   ├── generate-address.js
│   ├── fund-from-faucet.js
│   ├── open-hydra-head.js
│   ├── commit-fund.js
│   ├── send-payment.js
│   └── close-head.js
├── monitoring/            # Monitoring stack
│   ├── docker-compose.monitoring.yml
│   ├── grafana/
│   └── prometheus/
├── scripts/               # Automation scripts
│   ├── generator-keys.sh
│   ├── fund-address.sh
│   ├── start-hydra.sh
│   ├── stop-hydra.sh
│   ├── reset-all.sh
│   └── utils/
├── package.json           # NPM dependencies and scripts
├── .env.example           # Environment configuration template
└── README.md              # Main project README
```

## 🔧 Technology Stack

- **Node.js** (v18+): Runtime environment
- **Cardano**: Blockchain platform
- **Hydra Protocol**: Layer 2 scaling
- **Yaci DevKit**: Local development network
- **Docker**: Containerization
- **Lucid Evolution**: Cardano library
- **WebSocket**: Real-time communication

## 📚 Prerequisites

Before getting started, ensure you have:

- Node.js >= 18.0.0
- npm >= 9.0.0
- Docker (for Hydra nodes)
- Yaci DevKit
- curl, jq (command-line tools)

See the [Installation Guide](installation.md) for detailed setup instructions.

## 🎓 Learning Path

New to Hydra and Yaci? We recommend following this learning path:

1. **Start Here**: [Getting Started Guide](getting-started.md)
   - Understand the basics
   - Set up your environment
   - Run your first example

2. **Installation**: [Installation Guide](installation.md)
   - Install prerequisites
   - Configure the environment
   - Verify your setup

3. **Configuration**: [Configuration Guide](configuration.md)
   - Environment variables
   - Network settings
   - Participant configuration

4. **Usage**: [Usage Guide](usage.md)
   - Key generation
   - Wallet funding
   - Opening Hydra heads
   - Sending payments
   - Monitoring

5. **Troubleshooting**: [Troubleshooting Guide](troubleshooting.md)
   - Common issues
   - Debugging techniques
   - FAQ

6. **API Reference**: [API Reference](api-reference.md)
   - WebSocket API
   - Example scripts
   - NPM commands

## 🤝 Contributing

We welcome contributions! Please feel free to:

- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Cardano Scaling](https://github.com/cardano-scaling) - Hydra protocol
- [Yaci DevKit](https://devkit.yaci.xyz/) - Local development network
- [Lucid Evolution](https://github.com/lucid-evolution) - Cardano library

## 📞 Support

- GitHub Issues: Report bugs and request features
- Documentation: Browse guides in this docs folder
- Yaci DevKit Docs: [https://devkit.yaci.xyz/](https://devkit.yaci.xyz/)

---

**Author**: Kushal Acharya :)

**Version**: 1.0.0
