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
        text: 'Components',
        items: [
          { text: 'YesOrNoPrompt', link: '/components/yes-or-no-prompt' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/tuist/Command' }
    ]
  }
})