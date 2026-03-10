import { defineConfig } from "vite";

var pagesBase = "/DungeonBend2/";

export default defineConfig(({ command }) => ({
  base: command === "build" ? pagesBase : "/",
  build: {
    rollupOptions: {
      input: {
        main: "index.html",
        balance: "balance.html",
      },
    },
  },
}));
