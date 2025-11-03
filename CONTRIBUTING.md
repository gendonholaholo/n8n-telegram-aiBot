# Contributing to n8n Telegram AI Bot

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Issues

1. **Check existing issues** to avoid duplicates
2. **Use the issue template** if available
3. **Provide detailed information**:
   - Clear description of the issue
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (n8n version, PostgreSQL version, etc.)
   - Relevant logs or error messages

### Suggesting Features

1. Open an issue with the `enhancement` label
2. Describe the feature and its use case
3. Explain why it would be valuable
4. Provide examples if possible

### Code Contributions

#### Setting Up Development Environment

```bash
# Clone the repository
git clone git@github.com:gendonholaholo/n8n-telegram-aiBot.git
cd n8n-telegram-aiBot

# Setup database
createdb telegram_bot_dev
psql -d telegram_bot_dev -f database/schema.sql

# Import workflow to n8n
# Configure credentials
# Start testing
```

#### Development Workflow

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Test thoroughly
   - Update documentation if needed

4. **Commit your changes**
   ```bash
   git commit -m "Add: description of your changes"
   ```
   
   Use conventional commit messages:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for improvements
   - `Docs:` for documentation changes
   - `Refactor:` for code refactoring

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use a clear title and description
   - Reference related issues
   - Explain what changes were made and why

## 📝 Coding Guidelines

### n8n Workflow Changes

- **Document new nodes** with clear descriptions
- **Test all paths** in the workflow
- **Keep it modular** - separate concerns into different nodes
- **Add error handling** where appropriate

### SQL Changes

- **Use transactions** for multi-step operations
- **Add indexes** for frequently queried columns
- **Include comments** for complex queries
- **Test migrations** before committing

### Documentation

- **Keep README.md up to date** with new features
- **Add examples** for new functionality
- **Update installation guide** if setup changes
- **Document breaking changes** clearly

## 🧪 Testing

Before submitting a PR, please test:

1. **Basic functionality**
   - Bot responds to messages
   - Commands work correctly
   - Database operations succeed

2. **Edge cases**
   - Empty messages
   - Very long messages
   - Invalid commands
   - Database connection failures

3. **Performance**
   - Response time acceptable
   - No memory leaks
   - Database queries optimized

## 📋 Pull Request Checklist

- [ ] Code follows project style
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No sensitive data in commits
- [ ] Changes are backwards compatible (or documented)

## 🎯 Priority Areas

We especially welcome contributions in:

- **Features**: Voice message support, multi-language improvements
- **Performance**: Query optimization, caching strategies
- **Documentation**: Tutorials, video guides, translations
- **Testing**: Test cases, integration tests
- **Bug fixes**: Check the issues page

## 💬 Communication

- **GitHub Issues**: For bugs and feature requests
- **Pull Requests**: For code contributions
- **Discussions**: For questions and general discussion

## 📜 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

## 🙏 Recognition

All contributors will be:
- Listed in the project contributors
- Mentioned in release notes for significant contributions
- Given credit in documentation where appropriate

Thank you for contributing to make this project better! 🚀
