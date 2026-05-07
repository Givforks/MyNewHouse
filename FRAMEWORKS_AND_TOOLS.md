# 📚 Additional Framework & Tool Setup Guides

## Frontend Frameworks

### React Setup
```bash
npm install react react-dom
npm install --save-dev @vitejs/plugin-react vite
```

**ESLint for React:**
```bash
npm install --save-dev eslint-plugin-react eslint-plugin-react-hooks
```

Update `.eslintrc.json`:
```json
{
  "extends": ["airbnb", "airbnb/hooks"],
  "env": {
    "browser": true,
    "es2021": true
  },
  "rules": {
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off"
  }
}
```

---

## Backend Frameworks

### Express.js Setup
```bash
npm install express cors dotenv
npm install --save-dev nodemon
```

Add to `package.json`:
```json
{
  "scripts": {
    "dev": "nodemon src/index.js"
  }
}
```

---

## Database Setup

### MongoDB with Mongoose
```bash
npm install mongoose
```

### MySQL with mysql2
```bash
npm install mysql2 sequelize
```

---

## TypeScript Setup
```bash
npm install --save-dev typescript ts-node @types/node
npx tsc --init
```

Update `.eslintrc.json`:
```json
{
  "extends": ["airbnb-base"],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "no-use-before-define": "off",
    "@typescript-eslint/no-use-before-define": ["error"]
  }
}
```

---

## Testing

### Jest Setup
```bash
npm install --save-dev jest @babel/preset-env babel-jest
```

Create `jest.config.js`:
```javascript
export default {
  testEnvironment: 'node',
  collectCoverageFrom: ['src/**/*.js'],
  coveragePathIgnorePatterns: ['/node_modules/'],
};
```

---

## Docker

### Docker Setup (Already Configured)
- Docker daemon running on your system
- MongoDB container: `mongo-vscode-temp`
- MySQL running on `127.0.0.1:3306`

See: `DEV_TOOLS_SETUP.md`

---

## Environment Variables
Create `.env`:
```
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://user:pass@localhost:27017/dbname
MYSQL_HOST=127.0.0.1
MYSQL_USER=Givenchicodes
MYSQL_PASSWORD=YOUR_PASSWORD
```

**Never commit `.env` to Git!** Add to `.gitignore`:
```
.env
.env.local
```

---

## Useful NPM Packages for Full-Stack

| Package | Purpose |
|---------|---------|
| `express` | Web framework |
| `dotenv` | Environment variables |
| `cors` | Cross-origin requests |
| `mongoose` | MongoDB ODM |
| `sequelize` | SQL ORM |
| `jsonwebtoken` | JWT auth |
| `bcryptjs` | Password hashing |
| `axios` | HTTP client |
| `socket.io` | Real-time communication |

---

**Ready to use! Copy templates and extend as needed.**
