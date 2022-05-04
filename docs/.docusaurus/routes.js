
import React from 'react';
import ComponentCreator from '@docusaurus/ComponentCreator';

export default [
  {
    path: '/blog',
    component: ComponentCreator('/blog','17d'),
    exact: true
  },
  {
    path: '/blog/archive',
    component: ComponentCreator('/blog/archive','316'),
    exact: true
  },
  {
    path: '/blog/tags',
    component: ComponentCreator('/blog/tags','a5a'),
    exact: true
  },
  {
    path: '/blog/tags/hello',
    component: ComponentCreator('/blog/tags/hello','7fb'),
    exact: true
  },
  {
    path: '/blog/tags/tridentu',
    component: ComponentCreator('/blog/tags/tridentu','4fb'),
    exact: true
  },
  {
    path: '/blog/welcome',
    component: ComponentCreator('/blog/welcome','1e6'),
    exact: true
  },
  {
    path: '/markdown-page',
    component: ComponentCreator('/markdown-page','8ae'),
    exact: true
  },
  {
    path: '/docs',
    component: ComponentCreator('/docs','f14'),
    routes: [
      {
        path: '/docs/intro',
        component: ComponentCreator('/docs/intro','aed'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-extras/customization',
        component: ComponentCreator('/docs/tutorial-extras/customization','f53'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-extras/searching',
        component: ComponentCreator('/docs/tutorial-extras/searching','3cd'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-guides/applications',
        component: ComponentCreator('/docs/tutorial-guides/applications','f8a'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-guides/congratulations',
        component: ComponentCreator('/docs/tutorial-guides/congratulations','c0e'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-guides/places',
        component: ComponentCreator('/docs/tutorial-guides/places','d41'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-guides/tiles',
        component: ComponentCreator('/docs/tutorial-guides/tiles','0bb'),
        exact: true,
        sidebar: "tutorialSidebar"
      },
      {
        path: '/docs/tutorial-guides/workspaces',
        component: ComponentCreator('/docs/tutorial-guides/workspaces','cbc'),
        exact: true,
        sidebar: "tutorialSidebar"
      }
    ]
  },
  {
    path: '/',
    component: ComponentCreator('/','805'),
    exact: true
  },
  {
    path: '*',
    component: ComponentCreator('*')
  }
];
