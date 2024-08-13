import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Command",
  description: "A micro Swift Package for running system processes in Swift",
  titleTemplate: ':title | Command | Tuist',
  sitemap: {
    hostname: 'https://command.tuist.io'
  },
  themeConfig: {
    logo: "/logo.png",
    search: {
      provider: "local",
    },
    nav: [
      { text: "Changelog", link: "https://github.com/tuist/Command/releases" }
    ],
    editLink: {
      pattern: "https://github.com/tuist/Command/edit/main/docs/:path",
    },
    sidebar: [
      {
        text: 'Command',
        items: [
          { text: 'What is Command?', link: '/guides/what-is-command' },
          { text: 'Usage', link: '/guides/usage' },
        ]
      }
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
  }
})
