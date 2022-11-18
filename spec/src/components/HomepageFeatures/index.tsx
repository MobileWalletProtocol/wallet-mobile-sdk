import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Easy',
    description: (
      <>
        Simplified and improved wallet integration for native mobile applications 
        via deep-linking, without requiring a web application.
      </>
    ),
  },
  {
    title: 'Efficient',
    description: (
      <>
        Reduces the number of hops between client applications 
        and wallet via support for batch requests.
      </>
    ),
  },
  {
    title: 'Decentralized and reliable',
    description: (
      <>
        Doesn't depend on external services and relay servers 
        for delivering messages and app-to-wallet communication. 
      </>
    ),
  },
  {
    title: 'Secure',
    description: (
      <>
        Utilizes end-to-end encryption with secure key exchange 
        and decentralized identity verification using 
        the well-known URI standard for universal links.
      </>
    ),
  },
];

function Feature({title, description}: FeatureItem) {
  return (
    <div className={clsx('col col--3')}>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
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
