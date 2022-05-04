import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Easy to Use',
    Svg: require('@site/static/img/undraw_docusaurus_mountain.svg').default,
    description: (
      <>
        Saturn Launcher was designed to be as easy to use as the original Kickoff Launcher
        , but with more easy features (such as the Workspaces).
      </>
    ),
  },
  {
    title: 'Keep Organized',
    Svg: require('@site/static/img/undraw_docusaurus_tree.svg').default,
    description: (
      <>
        The Saturn Launcher lets you focus on what you want to do without taking up too much space.
        Want to launch an app (quite quickly) that you commonly use? Tiles has got you covered.
      </>
    ),
  },
  {
    title: 'Powered by Kicker & Kickoff',
    Svg: require('@site/static/img/undraw_docusaurus_react.svg').default,
    description: (
      <>
        Extend or customize your copy of the Saturn Launcher using the same features as Kickoff. Saturn Launcher even
        has the original custom icon feature from before too!
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
