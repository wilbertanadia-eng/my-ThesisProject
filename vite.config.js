import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
            publicDirectory: 'public',
        }),
    ],
    build: {
        outDir: 'public/build',
        manifest: true,
        minify: true,
    },
    server: {
        host: 'localhost',
        port: 5173,
        strictPort: false,
    }
})