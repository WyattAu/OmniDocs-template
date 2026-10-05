// @ts-check
import starlight from '@astrojs/starlight'
import { defineConfig } from 'astro/config'

export default defineConfig({
  site: 'https://wyattau.github.io/OmniDocs-template',
  base: '/OmniDocs-template',
  integrations: [
    starlight({
      title: 'OmniDocs',
      customCss: ['./src/styles/custom.css'],
      description: 'Documentation site — start here.',
      social: { github: 'https://github.com/WyattAu/OmniDocs-template' },
      sidebar: [
        {
          label: 'Guides',
          translations: { de: 'Leitfäden' },
          items: [{ label: 'Getting started', slug: 'guides/getting-started' }],
        },
        {
          label: 'Reference',
          autogenerate: { directory: 'reference' },
        },
      ],
    }),
  ],
})
