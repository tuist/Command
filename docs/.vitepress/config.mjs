import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Command",
  description: "A micro Swift Package for running system processes in Swift",
  sitemap: {
    hostname: 'https://command.tuist.io'
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' }
    ],

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
      { icon: 'github', link: 'https://github.com/tuist/Command' },
      { icon: 'x', link: 'https://x.com/tuistio' },
      { icon: 'mastodon', link: 'https://fosstodon.org/@tuist' },
      { icon: 'slack', link: 'https://fosstodon.org/@tuist' },
      { icon: 'discord', link: 'https://discord.gg/MnqrEMRFDj' }
    ]
  }
})
