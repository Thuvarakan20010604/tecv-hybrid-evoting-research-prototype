import { defineConfig } from 'vitest/config';
export default defineConfig({test:{include:['tests/**/*.test.ts'],exclude:['fabric/**','chaincode/**','node_modules/**'],coverage:{include:['apps/**/*.ts','packages/**/*.ts'],exclude:['apps/api/src/server.ts']}}});
