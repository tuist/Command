import { defineConfig } from "vitepress";
import { quickstartIcon } from "./icons.mjs";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Command",
  description: "A micro Swift Package for running system processes in Swift",
  titleTemplate: ":title | Command | Tuist",
  sitemap: {
    hostname: "https://command.tuist.io",
  },
  themeConfig: {
    logo: "/logo.png",
    search: {
      provider: "local",
    },
    nav: [
      { text: "Changelog", link: "https://github.com/tuist/Command/releases" },
    ],
    editLink: {
      pattern: "https://github.com/tuist/Command/edit/main/docs/:path",
    },
    sidebar: [
      {
        text: `<span style="display: flex; flex-direction: row; align-items: center; gap: 7px;">Quick start ${quickstartIcon()}</span>`,
        items: [
          { text: "Install", link: "/" },
          { text: "Run a command", link: "/quick-start/run-a-command" },
          { text: "Write tests", link: "/quick-start/write-tests" },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/tuist/tuist" },
      { icon: "x", link: "https://x.com/tuistio" },
      { icon: "mastodon", link: "https://fosstodon.org/@tuist" },
      {
        icon: "slack",
        link: "https://slack.tuist.io",
      },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024-present Tuist Inc.",
    },
  },
});
