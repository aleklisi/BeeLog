import { defineConfig } from 'vite';
import elmPlugin from 'vite-plugin-elm';

export default defineConfig({
  plugins: [
    elmPlugin(),
    {
      name: 'html-transform',
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          if (req.url === '/' || req.url === '/index.html') {
            req.url = '/frontend/index.html';
          }
          next();
        });
      }
    }
  ],
  root: '.',
  server: {
    port: 3000,
    hmr: {
      overlay: false
    }
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: 'frontend/index.html'
    }
  }
});
